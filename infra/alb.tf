# Application Load Balancer Module
module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name               = "${var.project_name}-alb"
  load_balancer_type = "application"
  vpc_id             = data.aws_vpc.default.id
  subnets            = data.aws_subnets.public_default.ids
  security_groups    = [module.alb_sg.security_group_id]

  enable_deletion_protection       = false
  enable_http2                     = true
  enable_cross_zone_load_balancing = true

  # Listeners (v9 API uses a map of listeners)
  listeners = {
    http_redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    https = {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate.main.arn

      forward = {
        target_group_key = "storefront"
      }

      rules = {
        api_host = {
          priority = 5
          actions = [{
            type             = "forward"
            target_group_key = "backend"
          }]
          conditions = [{
            host_header = {
              values = ["api.tindaph.app"]
            }
          }]
        }

        backend_api = {
          priority = 10
          actions = [{
            type             = "forward"
            target_group_key = "backend"
          }]
          conditions = [{
            path_pattern = {
              values = ["/api/*"]
            }
          }]
        }
      }
    }
  }

  # Target groups (v9 API uses a map of target groups)
  target_groups = {
    storefront = {
      name              = "${var.project_name}-storefront-tg"
      protocol          = "HTTP"
      port              = 8000
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        path                = "/"
        matcher             = "200-399"
      }
    }

    backend = {
      name              = "${var.project_name}-backend-tg"
      protocol          = "HTTP"
      port              = 9000
      target_type       = "ip"
      create_attachment = false

      health_check = {
        enabled             = true
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 10
        interval            = 30
        path                = "/health"
        matcher             = "200"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-alb" })
}
