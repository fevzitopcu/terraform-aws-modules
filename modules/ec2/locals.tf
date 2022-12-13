locals {
  env = {
    default = {
      instance_type  = "t2.micro"
      ami            = "ami-0f15e0a4c8d3ee5fe"
      instance_count = 1
    }
    dev = {
      instance_type  = "t3.micro"
      ami            = "ami-0f15e0a4c8d3ee5fe"
      instance_count = 2
    }
    qa = {
      instance_type  = "t3.micro"
      ami            = "ami-0f15e0a4c8d3ee5fe"
      instance_count = 3
    }
    prod = {
      instance_type  = "t3.micro"
      ami            = "ami-0f15e0a4c8d3ee5fe"
      instance_count = 6
    }
  }
  environmentvars = contains(keys(local.env), terraform.workspace) ? terraform.workspace : "default"
  workspace       = merge(local.env["default"], local.env[local.environmentvars])
}
