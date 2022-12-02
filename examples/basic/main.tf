terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.main.id
  tags = {
    Tier = "Private"
  }
}

module "lb" {
  source      = "../../"
  name_prefix = var.name_prefix
  vpc_id      = data.aws_vpc.main.id
  subnet_ids  = data.aws_subnet_ids.private.ids
  type        = "application"

  tags = {
    environment = "dev"
    terraform   = "True"
  }
}
