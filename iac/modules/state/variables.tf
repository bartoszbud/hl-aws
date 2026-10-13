variable "environment" {
  description = "Environment name"
  type        = string
}

variable "module_name" {
  description = "Module name"
  type        = string
}

/*variable "key_name" {
  description = "KMS key name for S3 bucket encryption"
  type        = string
}*/

variable "key_rotation" {
  description = "Enable key rotation"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "value"
  type        = number
  default     = 7
}