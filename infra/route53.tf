# A record: tindaph.app → storefront API Gateway custom domain
resource "aws_route53_record" "main" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.storefront.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.storefront.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# A record: api.tindaph.app → backend API Gateway custom domain
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.backend.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.backend.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# A record: admin.tindaph.app → backend API Gateway custom domain
resource "aws_route53_record" "admin" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "admin.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_apigatewayv2_domain_name.admin.domain_name_configuration[0].target_domain_name
    zone_id                = aws_apigatewayv2_domain_name.admin.domain_name_configuration[0].hosted_zone_id
    evaluate_target_health = false
  }
}

# A record: media.tindaph.app → CloudFront (unchanged)
resource "aws_route53_record" "media" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "media.${var.domain_name}"
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}
