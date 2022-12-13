provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket = "terraform-backend-fevzi"
    key    = "dev/terraform.tfstate"
    region = "eu-west-3"
  }
}


module "asg" {
  source = "../../modules/asg/"



}
