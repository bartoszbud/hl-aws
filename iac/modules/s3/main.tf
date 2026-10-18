data "aws_caller_identity" "current" {}

resource "aws_kms_key" "kms_key" {
  description             = "${var.environment} bucket encryption key"
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.key_rotation
}

resource "aws_kms_alias" "kms_key_alias" {
  target_key_id = aws_kms_key.kms_key.id
  name          = "alias/kms-${var.environment}-${var.module_name}"
}

resource "aws_s3_bucket" "bucket" {
  bucket        = "${var.environment}-${var.module_name}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = {
    Environment = var.environment
    Purpose     = "${var.module_name} bucket for ${var.environment} environment"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_public_access_config" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

resource "aws_s3_bucket_versioning" "bucket_versioning" {
  bucket = aws_s3_bucket.bucket.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle_config" {
  count  = var.enable_versioning ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "expire-old-versions"
    status = "Enabled"

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }

  depends_on = [aws_s3_bucket_versioning.bucket_versioning]
}

resource "aws_s3_bucket_server_side_encryption_configuration" "bucket_encryption" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_alias.kms_key_alias.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_logging" "bucket_logging" {
  count         = var.enable_logging ? 1 : 0
  bucket        = aws_s3_bucket.bucket.id
  target_bucket = aws_s3_bucket.bucket.id
  target_prefix = "logs/"
}

data "aws_iam_policy_document" "logging" {
  count = var.enable_logging ? 1 : 0

  statement {
    sid       = "S3ServerAccessLogs"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/logs/*"]

    principals {
      type        = "Service"
      identifiers = ["logging.s3.amazonaws.com"]
    }

    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.bucket.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
  }
}

data "aws_iam_policy_document" "bucket_policy" {
  source_policy_documents = var.enable_logging ? [data.aws_iam_policy_document.logging[0].json] : []

  statement {
    sid       = "DenyInsecureTransport"
    effect    = "Deny"
    actions   = ["s3:*"]
    resources = [aws_s3_bucket.bucket.arn, "${aws_s3_bucket.bucket.arn}/*"]

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
  }
}

resource "aws_s3_bucket_policy" "logging" {
  count  = var.enable_logging ? 1 : 0
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket_policy.json

  depends_on = [aws_s3_bucket_public_access_block.bucket_public_access_config]
}