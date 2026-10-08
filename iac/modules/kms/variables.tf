variable "key_name" {
  description = "KMS key name"
  type        = string
}

variable "key_description" {
  description = "Purpose of KMS key"
  type        = string
}

variable "key_rotation" {
  description = "Enable key rotation"
  type        = bool
  default     = true
}

variable "deletion_window_in_days" {
  description = "The waiting period before the KMS key is deleted"
  type        = number
  default     = 7
}
