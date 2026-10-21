variable "name" {
  description = "Name of IAM role"
  type        = string
}

variable "description" {
  description = "IAM role description"
  type        = string
}

variable "assume_role_policy" {
  description = "The JSON assume role policy document."
  type        = string
}

variable "policies" {
  description = "List of IAM policy ARNs to attach to the role."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "IAM role tags"
  type        = map(string)
}