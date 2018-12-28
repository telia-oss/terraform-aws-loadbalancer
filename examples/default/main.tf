terraform {
  required_version = "0.11.11"

  backend "s3" {
    key            = "terraform-modules/development/terraform-aws-vpc/default.tfstate"
    bucket         = "<test-account-id>-terraform-state"
    dynamodb_table = "<test-account-id>-terraform-state"
    acl            = "bucket-owner-full-control"
    encrypt        = "true"
    kms_key_id     = "<kms-key-id>"
    region         = "eu-west-1"
  }
}

provider "aws" {
  version             = "1.54.0"
  region              = "eu-west-1"
  allowed_account_ids = ["<test-account-id>"]
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
}



module "alb" {
  source      = "../../"
  name_prefix = "loadbalancer-default-test"
  vpc_id      = "${data.aws_vpc.main.id}"

  subnet_ids = [
    "${data.aws_subnet_ids.main.ids}",
  ]

  type = "application"

  tags {
    environment = "prod"
    terraform   = "True"
  }
}


