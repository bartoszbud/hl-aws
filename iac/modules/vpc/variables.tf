variable "environment" {
  description = "Environment name"
  type        = string
}

variable "module_name" {
  description = "Module name"
  type        = string
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrhost(var.cidr_block, 0))
    error_message = "The provided CIDR block is not valid."
  }
}

variable "subnet" {
  description = "Subnet map"
  type = map(object({
    cidr                    = string
    availability_zone       = string
    map_public_ip_on_launch = bool
  }))
}