

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
