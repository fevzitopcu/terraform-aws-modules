terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.40.0"
    }
  }
}

provider "aws" {

  region = var.aws_region
  
  default_tags {
    tags = {
      Team        = "${var.team-name}"
      Environment = "${terraform.workspace}"
      Tenant      = "${var.tenant}"
      Workspace   = "${terraform.workspace}"
    }
  }
}


data "aws_vpcs" "main-vpc" {
  filter {
    name   = "tag:Name"
    values = ["project-devops-team-vpc"]
  }
}

resource "aws_instance" "name" {

  instance_type = local.workspace["instance_type"]
  ami           = local.workspace["ami"]
  count         = local.workspace["instance_count"]

  key_name = "Fevzi-KeyPair"

  tags = {
    Name = "${var.project}-${terraform.workspace}-web-server"
  }
    
}