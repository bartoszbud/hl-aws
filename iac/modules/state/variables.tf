variable "environment" {
  description = "Environment name"
  type        = string
}

variable "module_name" {
  description = "Module name"
  type        = string
}

variable "key_name" {
  description = "KMS key name for S3 bucket encryption"
  type        = string
}