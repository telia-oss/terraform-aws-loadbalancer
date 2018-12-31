terraform {
  required_version = "0.11.11"

  backend "s3" {
    key            = "terraform-modules/development/terraform-aws-vpc/logs-bucket.tfstate"
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
  name_prefix = "alb-logs-bucket-test"
  vpc_id      = "${data.aws_vpc.main.id}"

  subnet_ids = [
    "${data.aws_subnet_ids.main.ids}",
  ]

  idle_timeout = 120
  type         = "application"

  tags {
    environment = "prod"
    terraform   = "True"
  }

  log_access = "true"
}

resource "aws_security_group_rule" "ingress_80" {
  security_group_id = "${module.alb.security_group_id}"
  type              = "ingress"
  protocol          = "tcp"
  from_port         = "80"
  to_port           = "80"

  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

output "access_logs_bucket_arn" {
  value = "${module.alb.access_logs_s3_bucket_arn}"
}
output "name" {
  value = "${module.alb.name}"
}