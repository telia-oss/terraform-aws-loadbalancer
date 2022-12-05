# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------
locals {
  name_prefix = "${var.name_prefix}-${var.type == "network" ? "nlb" : "alb"}"
}

resource "aws_lb" "main" {
  name                             = local.name_prefix
  load_balancer_type               = var.type
  internal                         = var.internal
  subnets                          = var.subnet_ids
  security_groups                  = aws_security_group.main.*.id
  idle_timeout                     = var.idle_timeout
  ip_address_type                  = var.ip_address_type
  enable_cross_zone_load_balancing = var.enable_cross_zone_load_balancing
  enable_deletion_protection       = var.enable_deletion_protection

  access_logs {
    bucket  = lookup(var.access_logs, "bucket", "")
    prefix  = lookup(var.access_logs, "prefix", null)
    enabled = lookup(var.access_logs, "enabled", false)
  }

  tags = merge(
    var.tags,
    {
      "Name" = local.name_prefix
    },
  )
}

resource "aws_security_group" "main" {
  count       = var.type == "network" ? 0 : 1
  name        = "${local.name_prefix}-sg"
  description = "Terraformed security group."
  vpc_id      = var.vpc_id

  tags = merge(
    var.tags,
    {
      "Name" = "${local.name_prefix}-sg"
    },
  )
}

resource "aws_security_group_rule" "egress" {
  count             = var.type == "network" ? 0 : 1
  security_group_id = aws_security_group.main[0].id
  type              = "egress"
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
