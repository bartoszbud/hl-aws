resource "aws_kms_key" "kms_key" {
  description             = var.key_description
  deletion_window_in_days = 7
  enable_key_rotation     = true
}

resource "aws_kms_alias" "kms_key_alias" {
  target_key_id = aws_kms_key.kms_key.id
  name          = "alias/${var.key_name}"
}