# API Gateway HTTP API — Backend (api.tindaph.app)
resource "aws_apigatewayv2_api" "backend" {
  name          = "${var.project_name}-backend-api"
  protocol_type = "HTTP"

  cors_configuration {
    allow_origins = [
      "https://${var.domain_name}",
      "https://admin.${var.domain_name}",
      "https://www.${var.domain_name}"
    ]
    allow_methods = ["*"]
    allow_headers = ["*"]
    max_age       = 300
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-api" })
}

resource "aws_apigatewayv2_integration" "backend" {
  api_id                 = aws_apigatewayv2_api.backend.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.backend.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "backend_default" {
  api_id    = aws_apigatewayv2_api.backend.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.backend.id}"
}

resource "aws_cloudwatch_log_group" "backend_apigw" {
  name              = "/aws/apigateway/${var.project_name}-backend"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-backend-apigw-logs" })
}

resource "aws_apigatewayv2_stage" "backend" {
  api_id      = aws_apigatewayv2_api.backend.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.backend_apigw.arn
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-stage" })
}

resource "aws_lambda_permission" "backend_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.backend.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.backend.execution_arn}/*/*"
}

# Custom domain: api.tindaph.app → backend API
resource "aws_apigatewayv2_domain_name" "backend" {
  domain_name = "api.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-domain" })

  depends_on = [aws_acm_certificate_validation.main]
}

resource "aws_apigatewayv2_api_mapping" "backend" {
  api_id      = aws_apigatewayv2_api.backend.id
  domain_name = aws_apigatewayv2_domain_name.backend.id
  stage       = aws_apigatewayv2_stage.backend.id
}

# Custom domain: admin.tindaph.app → backend API
resource "aws_apigatewayv2_domain_name" "admin" {
  domain_name = "admin.${var.domain_name}"

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-admin-domain" })

  depends_on = [aws_acm_certificate_validation.main]
}

resource "aws_apigatewayv2_api_mapping" "admin" {
  api_id      = aws_apigatewayv2_api.backend.id
  domain_name = aws_apigatewayv2_domain_name.admin.id
  stage       = aws_apigatewayv2_stage.backend.id
}

# API Gateway HTTP API — Storefront (tindaph.app)
resource "aws_apigatewayv2_api" "storefront" {
  name          = "${var.project_name}-storefront-api"
  protocol_type = "HTTP"

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-api" })
}

resource "aws_apigatewayv2_integration" "storefront" {
  api_id                 = aws_apigatewayv2_api.storefront.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.storefront.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "storefront_default" {
  api_id    = aws_apigatewayv2_api.storefront.id
  route_key = "$default"
  target    = "integrations/${aws_apigatewayv2_integration.storefront.id}"
}

resource "aws_cloudwatch_log_group" "storefront_apigw" {
  name              = "/aws/apigateway/${var.project_name}-storefront"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-apigw-logs" })
}

resource "aws_apigatewayv2_stage" "storefront" {
  api_id      = aws_apigatewayv2_api.storefront.id
  name        = "$default"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.storefront_apigw.arn
  }

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-stage" })
}

resource "aws_lambda_permission" "storefront_apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.storefront.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.storefront.execution_arn}/*/*"
}

# Custom domain: tindaph.app → storefront
resource "aws_apigatewayv2_domain_name" "storefront" {
  domain_name = var.domain_name

  domain_name_configuration {
    certificate_arn = aws_acm_certificate.main.arn
    endpoint_type   = "REGIONAL"
    security_policy = "TLS_1_2"
  }

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-domain" })

  depends_on = [aws_acm_certificate_validation.main]
}

resource "aws_apigatewayv2_api_mapping" "storefront" {
  api_id      = aws_apigatewayv2_api.storefront.id
  domain_name = aws_apigatewayv2_domain_name.storefront.id
  stage       = aws_apigatewayv2_stage.storefront.id
}
