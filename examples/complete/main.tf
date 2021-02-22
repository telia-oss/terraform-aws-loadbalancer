terraform {
  required_version = ">= 0.14"
}

provider "aws" {
  region = var.region
}

data "aws_vpc" "main" {
  default = true
}

data "aws_subnet_ids" "main" {
  vpc_id = data.aws_vpc.main.id
}

# NOTE: You will have apply twice (or create the bucket first) due to a AWS provider issue.
# This has to do with the aws_s3_bucket and not the module. See e2e tests for more details.
resource "aws_s3_bucket" "bucket" {
  bucket_prefix = var.name_prefix
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

# Ref: https://docs.aws.amazon.com/elasticloadbalancing/latest/network/load-balancer-access-logs.html
# (ALB: https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions)
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "bucket" {
  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect    = "Allow"
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"
      values   = ["bucket-owner-full-control"]
    }
  }

  statement {
    principals {
      type        = "Service"
      identifiers = ["delivery.logs.amazonaws.com"]
    }

    effect    = "Allow"
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.bucket.arn]
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
