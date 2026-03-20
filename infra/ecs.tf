# CloudWatch Log Groups for Lambda functions
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/aws/lambda/${var.project_name}-backend"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-backend-logs" })
}

resource "aws_cloudwatch_log_group" "storefront" {
  name              = "/aws/lambda/${var.project_name}-storefront"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-logs" })
}

resource "aws_cloudwatch_log_group" "backend_migrate" {
  name              = "/aws/lambda/${var.project_name}-backend-migrate"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-backend-migrate-logs" })
}

resource "aws_cloudwatch_log_group" "backend_scripts" {
  name              = "/aws/lambda/${var.project_name}-backend-scripts"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-backend-scripts-logs" })
}

# Read SSM secrets to inject into Lambda environment variables
data "aws_ssm_parameter" "lambda_database_url" {
  name            = aws_ssm_parameter.database_url.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.database_url]
}

data "aws_ssm_parameter" "lambda_redis_url" {
  name            = aws_ssm_parameter.redis_url.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.redis_url]
}

data "aws_ssm_parameter" "lambda_jwt_secret" {
  name            = aws_ssm_parameter.jwt_secret.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.jwt_secret]
}

data "aws_ssm_parameter" "lambda_cookie_secret" {
  name            = aws_ssm_parameter.cookie_secret.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.cookie_secret]
}

data "aws_ssm_parameter" "lambda_payrex_secret_key" {
  name            = aws_ssm_parameter.payrex_secret_key.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.payrex_secret_key]
}

data "aws_ssm_parameter" "lambda_payrex_webhook_secret" {
  name            = aws_ssm_parameter.payrex_webhook_secret.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.payrex_webhook_secret]
}

data "aws_ssm_parameter" "lambda_medusa_publishable_key" {
  name            = aws_ssm_parameter.medusa_publishable_key.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.medusa_publishable_key]
}

data "aws_ssm_parameter" "lambda_revalidate_secret" {
  name            = aws_ssm_parameter.revalidate_secret.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.revalidate_secret]
}

data "aws_ssm_parameter" "lambda_payrex_publishable_key" {
  name            = aws_ssm_parameter.payrex_publishable_key.name
  with_decryption = true
  depends_on      = [aws_ssm_parameter.payrex_publishable_key]
}

locals {
  backend_env = {
    NODE_ENV                     = "production"
    PORT                         = "9000"
    AWS_LWA_PORT                 = "9000"
    AWS_LWA_READINESS_CHECK_PATH = "/health"
    MEDUSA_BACKEND_URL           = "https://api.${var.domain_name}"
    DATABASE_URL                 = data.aws_ssm_parameter.lambda_database_url.value
    REDIS_URL                    = data.aws_ssm_parameter.lambda_redis_url.value
    JWT_SECRET                   = data.aws_ssm_parameter.lambda_jwt_secret.value
    COOKIE_SECRET                = data.aws_ssm_parameter.lambda_cookie_secret.value
    PAYREX_SECRET_KEY            = data.aws_ssm_parameter.lambda_payrex_secret_key.value
    PAYREX_WEBHOOK_SECRET        = data.aws_ssm_parameter.lambda_payrex_webhook_secret.value
  }
}

# Backend Lambda — HTTP server using Lambda Web Adapter
resource "aws_lambda_function" "backend" {
  function_name = "${var.project_name}-backend"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.backend.repository_url}:latest"
  role          = aws_iam_role.lambda_execution_role.arn

  timeout     = 29
  memory_size = var.backend_memory

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [module.lambda_sg.security_group_id]
  }

  environment {
    variables = local.backend_env
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-lambda" })

  depends_on = [aws_cloudwatch_log_group.backend]
}

# Backend Migration Lambda — runs db:migrate (no LWA, different CMD)
resource "aws_lambda_function" "backend_migrate" {
  function_name = "${var.project_name}-backend-migrate"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.backend.repository_url}:latest"
  role          = aws_iam_role.lambda_execution_role.arn

  timeout     = 300
  memory_size = 1024

  image_config {
    command = ["yarn", "medusa", "db:migrate"]
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [module.lambda_sg.security_group_id]
  }

  environment {
    variables = {
      NODE_ENV      = "production"
      DATABASE_URL  = data.aws_ssm_parameter.lambda_database_url.value
      REDIS_URL     = data.aws_ssm_parameter.lambda_redis_url.value
      JWT_SECRET    = data.aws_ssm_parameter.lambda_jwt_secret.value
      COOKIE_SECRET = data.aws_ssm_parameter.lambda_cookie_secret.value
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-migrate-lambda" })

  depends_on = [aws_cloudwatch_log_group.backend_migrate]
}

# Backend Scripts Lambda — runs one-off scripts (publishable key, etc.)
resource "aws_lambda_function" "backend_scripts" {
  function_name = "${var.project_name}-backend-scripts"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.backend.repository_url}:latest"
  role          = aws_iam_role.lambda_execution_role.arn

  timeout     = 300
  memory_size = 1024

  image_config {
    command = ["yarn", "medusa", "exec", "./src/scripts/create-publishable-key.ts"]
  }

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [module.lambda_sg.security_group_id]
  }

  environment {
    variables = local.backend_env
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-scripts-lambda" })

  depends_on = [aws_cloudwatch_log_group.backend_scripts]
}

# Storefront Lambda — Next.js HTTP server using Lambda Web Adapter
resource "aws_lambda_function" "storefront" {
  function_name = "${var.project_name}-storefront"
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.storefront.repository_url}:latest"
  role          = aws_iam_role.lambda_execution_role.arn

  timeout     = 29
  memory_size = var.storefront_memory

  vpc_config {
    subnet_ids         = aws_subnet.private[*].id
    security_group_ids = [module.lambda_sg.security_group_id]
  }

  environment {
    variables = {
      NODE_ENV                           = "production"
      PORT                               = "8000"
      AWS_LWA_PORT                       = "8000"
      AWS_LWA_READINESS_CHECK_PATH       = "/api/health"
      NEXT_PUBLIC_BASE_URL               = "https://${var.domain_name}"
      MEDUSA_BACKEND_URL                 = "https://api.${var.domain_name}"
      NEXT_PUBLIC_MEDUSA_BACKEND_URL     = "https://api.${var.domain_name}"
      NEXT_PUBLIC_DEFAULT_REGION         = "ph"
      NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY = data.aws_ssm_parameter.lambda_medusa_publishable_key.value
      REVALIDATE_SECRET                  = data.aws_ssm_parameter.lambda_revalidate_secret.value
      NEXT_PUBLIC_PAYREX_PUBLIC_KEY      = data.aws_ssm_parameter.lambda_payrex_publishable_key.value
    }
  }

  lifecycle {
    ignore_changes = [image_uri]
  }

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-lambda" })

  depends_on = [aws_cloudwatch_log_group.storefront]
}
