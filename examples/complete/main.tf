terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  version = ">= 2.17"
  region  = var.region
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

# NOTE: You might have apply twice because of a AWS provider issue. See e2e tests for more details.
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.name_prefix
  region        = var.region
  acl           = "private"
  force_destroy = true

  tags = {
    environment = "dev"
    terraform   = "True"
  }
}

resource "aws_s3_bucket_policy" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  policy = data.aws_iam_policy_document.bucket.json
}

data "aws_caller_identity" "current" {}

# Ref: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
data "aws_iam_policy_document" "bucket" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [var.elastic_loadbalancing_account_id]
    }
    sid       = "accesslogs"
    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]
  }
}

module "lb" {
  source      = "../../"
  name_prefix = var.name_prefix
  vpc_id      = data.aws_vpc.main.id
  subnet_ids  = data.aws_subnet_ids.main.ids
  type        = "network"

  access_logs = {
    bucket  = aws_s3_bucket.bucket.id
    enabled = true
  }

  tags = {
    environment = "dev"
    terraform   = "True"
  }
}
