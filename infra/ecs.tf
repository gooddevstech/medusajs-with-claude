# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "backend" {
  name              = "/ecs/${var.project_name}-backend"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-backend-logs" })
}

resource "aws_cloudwatch_log_group" "storefront" {
  name              = "/ecs/${var.project_name}-storefront"
  retention_in_days = 7

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-logs" })
}

# ECS Cluster using terraform-aws-modules
module "ecs" {
  source  = "terraform-aws-modules/ecs/aws"
  version = "~> 5.0"

  cluster_name = "${var.project_name}-ecs"

  # Cluster configuration
  cluster_settings = [
    {
      name  = "containerInsights"
      value = "enabled"
    }
  ]

  # Services (will be managed separately for flexibility)
  services = {}

  tags = merge(var.tags, { Name = "${var.project_name}-ecs-cluster" })
}

# Backend ECS Task Definition
resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.backend_cpu
  memory                   = var.backend_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "backend"
      image     = "${aws_ecr_repository.backend.repository_url}:latest"
      essential = true
      portMappings = [
        {
          name          = "backend"
          containerPort = 9000
          hostPort      = 9000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "MEDUSA_BACKEND_URL"
          value = "https://api.${var.domain_name}"
        },
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = "9000"
        }
      ]
      secrets = [
        {
          name      = "DATABASE_HOST"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/database_host"
        },
        {
          name      = "DATABASE_NAME"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/database_name"
        },
        {
          name      = "DATABASE_USERNAME"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/database_username"
        },
        {
          name      = "DATABASE_PASSWORD"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/database_password"
        },
        {
          name      = "DATABASE_URL"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/database_url"
        },
        {
          name      = "REDIS_URL"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/redis_url"
        },
        {
          name      = "JWT_SECRET"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/jwt_secret"
        },
        {
          name      = "COOKIE_SECRET"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/cookie_secret"
        },
        {
          name      = "PAYREX_WEBHOOK_SECRET"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/payrex_webhook_secret"
        },
        {
          name      = "PAYREX_SECRET_KEY"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/payrex_secret_key"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.backend.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.project_name}-backend-task-def" })
}

# Storefront ECS Task Definition
resource "aws_ecs_task_definition" "storefront" {
  family                   = "${var.project_name}-storefront"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.storefront_cpu
  memory                   = var.storefront_memory
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "storefront"
      image     = "${aws_ecr_repository.storefront.repository_url}:latest"
      essential = true
      portMappings = [
        {
          name          = "storefront"
          containerPort = 8000
          hostPort      = 8000
          protocol      = "tcp"
        }
      ]
      environment = [
        {
          name  = "NODE_ENV"
          value = "production"
        },
        {
          name  = "PORT"
          value = "8000"
        },
        {
          name  = "NEXT_PUBLIC_BASE_URL"
          value = "https://${var.domain_name}"
        },
        {
          name  = "NEXT_PUBLIC_MEDUSA_BACKEND_URL"
          value = "https://api.${var.domain_name}"
        },
        {
          name  = "NEXT_PUBLIC_DEFAULT_REGION"
          value = "ph"
        }
      ]
      secrets = [
        {
          name      = "NEXT_PUBLIC_MEDUSA_PUBLISHABLE_KEY"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/medusa_publishable_key"
        },
        {
          name      = "REVALIDATE_SECRET"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/revalidate_secret"
        },
        {
          name      = "NEXT_PUBLIC_PAYREX_PUBLIC_KEY"
          valueFrom = "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.project_name}/payrex_publishable_key"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.storefront.name
          "awslogs-region"        = data.aws_region.current.name
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-task-def" })
}

# Backend ECS Service
resource "aws_ecs_service" "backend" {
  name             = "${var.project_name}-backend"
  cluster          = module.ecs.cluster_id
  task_definition  = aws_ecs_task_definition.backend.arn
  desired_count    = var.backend_desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = data.aws_subnets.public_default.ids
    security_groups  = [module.ecs_tasks_sg.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["backend"].arn
    container_name   = "backend"
    container_port   = 9000
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = "${var.project_name}-backend-service" })

  depends_on = [
    aws_ecs_task_definition.backend,
    module.alb
  ]
}

# Storefront ECS Service
resource "aws_ecs_service" "storefront" {
  name             = "${var.project_name}-storefront"
  cluster          = module.ecs.cluster_id
  task_definition  = aws_ecs_task_definition.storefront.arn
  desired_count    = var.storefront_desired_count
  launch_type      = "FARGATE"
  platform_version = "LATEST"

  network_configuration {
    subnets          = data.aws_subnets.public_default.ids
    security_groups  = [module.ecs_tasks_sg.security_group_id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = module.alb.target_groups["storefront"].arn
    container_name   = "storefront"
    container_port   = 8000
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  tags = merge(var.tags, { Name = "${var.project_name}-storefront-service" })

  depends_on = [
    aws_ecs_task_definition.storefront,
    module.alb
  ]
}

# Auto Scaling Target for Backend
resource "aws_appautoscaling_target" "backend_target" {
  max_capacity       = var.backend_max_capacity
  min_capacity       = var.backend_desired_count
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.backend.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Backend CPU
resource "aws_appautoscaling_policy" "backend_cpu" {
  name               = "${var.project_name}-backend-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.backend_target.resource_id
  scalable_dimension = aws_appautoscaling_target.backend_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.backend_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

# Auto Scaling Target for Storefront
resource "aws_appautoscaling_target" "storefront_target" {
  max_capacity       = var.storefront_max_capacity
  min_capacity       = var.storefront_desired_count
  resource_id        = "service/${module.ecs.cluster_name}/${aws_ecs_service.storefront.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# Auto Scaling Policy for Storefront CPU
resource "aws_appautoscaling_policy" "storefront_cpu" {
  name               = "${var.project_name}-storefront-cpu-autoscaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.storefront_target.resource_id
  scalable_dimension = aws_appautoscaling_target.storefront_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.storefront_target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}