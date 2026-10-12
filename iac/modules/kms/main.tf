resource "aws_kms_key" "kms_key" {
  description             = var.key_description
  deletion_window_in_days = var.deletion_window_in_days
  enable_key_rotation     = var.key_rotation
}

resource "aws_kms_alias" "kms_key_alias" {
  target_key_id = aws_kms_key.kms_key.id
  name          = "alias/${var.key_name}"
}