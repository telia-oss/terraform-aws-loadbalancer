provider "aws" {
  region = "eu-west-1"
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = "${data.aws_vpc.main.id}"
}

module "alb" {
  source      = "../../"
  name_prefix = "example"
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

  access_logs_bucket = "${aws_s3_bucket.elb.bucket}"
}

module "alb_nobucket" {
  source      = "../../"
  name_prefix = "example-2"
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

// The account 156460612806 must be added to writers to enable ELB logs (eu-west-1)
// see https://docs.aws.amazon.com/elasticloadbalancing/latest/classic/enable-access-logs.html

resource "aws_s3_bucket" "elb" {
  bucket = "terraform-aws-loadbalancer-changeme"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "AWS": "arn:aws:iam::156460612806:root"
    },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::terraform-aws-loadbalancer-changeme/*"
    }
  ]
  }
  EOF
}

output "s3_bukcet_arn" {
  value = "${aws_s3_bucket.elb.arn}"
}
