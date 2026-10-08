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

resource "aws_s3_bucket_logging" "state_bucket_logging" {
  bucket = aws_s3_bucket.state.id

  target_bucket = aws_s3_bucket.state_logs.id
  target_prefix = "logs/"
}

# disable state logs bucket logging check - no need to enable logging for this bucket as it is used for storing logs from other buckets
#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "state_logs" {
  bucket_prefix = "${var.environment}-${var.module_name}-state-logs-"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "${var.module_name} state logs bucker for ${var.environment} environment"
  }
}

resource "aws_s3_bucket_public_access_block" "state_logs_bucket_public_access_block" {
  bucket = aws_s3_bucket.state_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_lifecycle_configuration" "state_logs_bucket_lifecycle_config" {
  bucket = aws_s3_bucket.state_logs.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    expiration {
      days = 30
    }
  }
}

#ignore state access logs bucket encryption with customer key - logs only
#tfsec:ignore:aws-s3-encryption-customer-key