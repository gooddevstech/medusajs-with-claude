# S3 Bucket for Media using terraform-aws-modules
module "s3_media" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = "${var.project_name}-media-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  # Versioning
  versioning = {
    enabled = true
  }

  # Server-side encryption
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  # Block public access
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  # Lifecycle rules
  lifecycle_rule = [
    {
      id     = "keep-versions"
      status = "Enabled"

      noncurrent_version_expiration = {
        days = 30
      }
    }
  ]

  # CORS configuration for storefront
  cors_rule = [
    {
      allowed_headers = ["*"]
      allowed_methods = ["GET", "HEAD", "PUT", "POST", "DELETE"]
      allowed_origins = ["https://${var.domain_name}", "https://api.${var.domain_name}"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    }
  ]

  tags = merge(var.tags, { Name = "${var.project_name}-media-bucket" })
}

# CloudFront Origin Access Identity
resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for ${var.project_name} S3 media bucket"
}

# S3 Bucket Policy to allow CloudFront OAI
resource "aws_s3_bucket_policy" "media_policy" {
  bucket = module.s3_media.s3_bucket_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontOAI"
        Effect = "Allow"
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.s3_oai.iam_arn
        }
        Action   = "s3:GetObject"
        Resource = "${module.s3_media.s3_bucket_arn}/*"
      }
    ]
  })
}