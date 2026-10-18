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

variable "security_groups" {
  description = "Map of security groups"
  type = map(object({
    name        = string
    description = string
    ingress = map(object({
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_ipv4   = optional(list(string))
      sg          = optional(list(string))
      description = optional(string)
    }))
    egress = optional(map(object({
      protocol    = string
      from_port   = number
      to_port     = number
      cidr_ipv4   = optional(list(string))
      sg          = optional(list(string))
      description = optional(string)
    })))
  }))
}