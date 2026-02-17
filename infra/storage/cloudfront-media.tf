# CloudFront Distribution using terraform-aws-modules
module "cloudfront" {
  source = "terraform-aws-modules/cloudfront/aws"
  version = "~> 3.0"

  enabled            = true
  is_ipv6_enabled    = true
  comment            = "${var.project_name} media CDN"
  default_root_object = ""

  origin = {
    s3_bucket = {
      domain_name = module.s3_media.s3_bucket_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = aws_cloudfront_origin_access_identity.s3_oai.etag
      }
    }
  }

  default_cache_behavior = {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "s3_bucket"
    compress         = true
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
      headers = ["Origin"]
    }

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  viewer_certificate = {
    cloudfront_default_certificate = true
  }

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-cloudfront-media" })
}

# Route53 alias record for media subdomain (created in networking/route53.tf)