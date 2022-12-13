variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-3"
}

variable "project" {
  description = "The name of the project"
  type        = string
  default     = "project"
}

variable "team-name" {
  description = "The Project Name"
  type        = string
  default     = "devops-team"
}

variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
  type        = string
  default     = "10.0.0.0/16"

}

variable "availability_zones" {
  type        = list(any)
  description = "The names of the availability zones to use"
}

variable "environment" {
  description = "The deployment environment"
  type        = string
  default     = "default"

}

variable "tenant" {
  description = "The tenant"
  type        = string
  default     = "host"

}

# variable "workspace" {
#   description = "The terraform workspace"
#   type        = string
#   default     = "default"

# }

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"

}
variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"

}

