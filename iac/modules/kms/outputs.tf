output "kms_key_arn" {
  value = aws_kms_key.kms_key.arn
}

output "kms_key_alias" {
  value = aws_kms_alias.kms_key_alias.name
}