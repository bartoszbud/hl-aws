data "aws_caller_identity" "current" {}

resource "aws_kms_key" "kms_key" {
  description             = "${var.environment} state bucket key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.key_rotation
}

resource "aws_kms_alias" "kms_key_alias" {
  target_key_id = aws_kms_key.kms_key.id
  name          = "alias/kms-${var.environment}-${var.module_name}"
}

resource "aws_s3_bucket" "state" {
  bucket_prefix = "${var.environment}-state-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "State bucket for ${var.environment} environment"
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

#tfsec:ignore:aws-s3-enable-versioning
#tfsec:ignore:aws-s3-enable-bucket-logging
resource "aws_s3_bucket" "state_logs" {
  bucket_prefix = "${var.environment}-${var.module_name}-state-logs-"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "${var.module_name} state logs bucket for ${var.environment} environment"
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

resource "aws_s3_bucket_server_side_encryption_configuration" "state_encryption" {
  bucket = aws_s3_bucket.state.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.kms_key_alias.arn
      sse_algorithm     = "aws:kms"
    }

  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_logs_encryption" {
  bucket = aws_s3_bucket.state_logs.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.kms_key_alias.arn
      sse_algorithm     = "aws:kms"
    }
  }
}