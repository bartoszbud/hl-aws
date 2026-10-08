resource "aws_s3_bucket" "state" {
  bucket_prefix = "${var.environment}-${var.module_name}-state-"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "${var.module_name} state bucker for ${var.environment} environment"
  }
}

resource "aws_s3_bucket_public_access_block" "state_bucket_public_access_block" {
  bucket = aws_s3_bucket.state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "state_bucket_lifecycle_config" {
  bucket = aws_s3_bucket.state.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}