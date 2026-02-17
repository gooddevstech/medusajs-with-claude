# Application Load Balancer Module
module "alb" {
  source = "terraform-aws-modules/alb/aws"
  version = "~> 9.0"

  name            = "${var.project_name}-alb"
  load_balancer_type = "application"
  vpc_id          = data.aws_vpc.default.id
  subnets         = data.aws_subnets.public_default.ids
  security_groups = [module.alb_sg.security_group_id]

  enable_deletion_protection = false
  enable_http2              = true
  enable_cross_zone_load_balancing = true

  # HTTPS listener
  https_listeners = [
    {
      port            = 443
      protocol        = "HTTPS"
      certificate_arn = aws_acm_certificate_validation.main.certificate_arn
      action_type     = "forward"
      target_group_index = 0  # Default to storefront
    }
  ]

  # HTTP -> HTTPS redirect
  http_listeners = [
    {
      port        = 80
      protocol    = "HTTP"
      action_type = "redirect"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }
  ]

  # Target groups
  target_groups = [
    {
      name            = "${var.project_name}-storefront-tg"
      backend_protocol = "HTTP"
      backend_port    = 8000
      target_type     = "ip"
      health_check = {
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
        path                = "/"
        matcher             = "200"
      }
    },
    {
      name            = "${var.project_name}-backend-tg"
      backend_protocol = "HTTP"
      backend_port    = 9000
      target_type     = "ip"
      health_check = {
        healthy_threshold   = 2
        unhealthy_threshold = 3
        timeout             = 5
        interval            = 30
        path                = "/admin"
        matcher             = "200-399"
      }
    }
  ]

  tags = merge(var.tags, { Name = "${var.project_name}-alb" })
}