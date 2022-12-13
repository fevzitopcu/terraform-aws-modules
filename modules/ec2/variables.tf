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

variable "workspace" {
  description = "The terraform workspace"
  type        = string
  default     = "default"

}