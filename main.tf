# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------
locals {
  name_prefix = "${var.name_prefix}-${var.type == "network" ? "nlb" : "alb"}"
}

resource "aws_lb" "main" {
  count = "${var.access_logs_bucket == "" ? 1 : 0}"

  name               = "${local.name_prefix}"
  load_balancer_type = "${var.type}"
  internal           = "${var.internal}"
  subnets            = ["${var.subnet_ids}"]
  security_groups    = ["${aws_security_group.main.*.id}"]

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}"))}"
}

resource "aws_lb" "main_with_access_logs" {
  count              = "${var.access_logs_bucket == "" ? 0 : 1}"
  name               = "${local.name_prefix}"
  load_balancer_type = "${var.type}"
  internal           = "${var.internal}"
  subnets            = ["${var.subnet_ids}"]
  security_groups    = ["${aws_security_group.main.*.id}"]

  access_logs = {
    prefix  = "${var.access_logs_prefix}"
    bucket  = "${var.access_logs_bucket}"
    enabled = "true"
  }

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}"))}"
}

resource "aws_lb_ssl_negotiation_policy" "main" {
  name          = "${local.name_prefix}-tls-policy"
  load_balancer = "${aws_lb.*.id}"
  lb_port       = 443

  attribute {
    name  = "Protocol-TLSv1"
    value = "false"
  }

  attribute {
    name  = "Protocol-TLSv1.1"
    value = "false"
  }

  attribute {
    name  = "Protocol-TLSv1.2"
    value = "true"
  }

  attribute {
    name  = "Server-Defined-Cipher-Order"
    value = "true"
  }

  attribute {
    name  = "ECDHE-RSA-AES128-GCM-SHA256"
    value = "true"
  }

  attribute {
    name  = "AES128-GCM-SHA256"
    value = "true"
  }

  attribute {
    name  = "EDH-RSA-DES-CBC3-SHA"
    value = "false"
  }
}

resource "aws_security_group" "main" {
  count       = "${var.type == "network" ? 0 : 1}"
  name        = "${local.name_prefix}-sg"
  description = "Terraformed security group."
  vpc_id      = "${var.vpc_id}"

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}-sg"))}"
}

resource "aws_security_group_rule" "egress" {
  count             = "${var.type == "network" ? 0 : 1}"
  security_group_id = "${aws_security_group.main.id}"
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
