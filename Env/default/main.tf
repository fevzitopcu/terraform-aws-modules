provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-fevzi"
    key    = "default/terraform.tfstate"
    region = "eu-west-3"
  }
}

module "vpc" {
  source = "../../modules/vpc/"

  aws_region           = var.aws_region
  project              = var.project
  environment          = var.environment
  team-name            = var.team-name
  tenant               = var.tenant
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
  vpc_cidr             = var.vpc_cidr

}
