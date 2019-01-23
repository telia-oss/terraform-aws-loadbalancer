# ------------------------------------------------------------------------------
# Resources
# ------------------------------------------------------------------------------
locals {
  name_prefix = "${var.name_prefix}-${var.type == "network" ? "nlb" : "alb"}"
}

data "aws_region" "current" {}

resource "aws_lb" "main" {
  count = "${var.access_logs_bucket == "" ? 1 : 0}"

  name               = "${local.name_prefix}"
  load_balancer_type = "${var.type}"
  internal           = "${var.internal}"
  subnets            = ["${var.subnet_ids}"]
  security_groups    = ["${aws_security_group.main.*.id}"]
  idle_timeout       = "${var.idle_timeout}"

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}"))}"
}

resource "aws_lb" "main_with_access_logs" {
  count              = "${var.access_logs_bucket == "" ? 0 : 1}"
  name               = "${local.name_prefix}"
  load_balancer_type = "${var.type}"
  internal           = "${var.internal}"
  subnets            = ["${var.subnet_ids}"]
  security_groups    = ["${aws_security_group.main.*.id}"]
  idle_timeout       = "${var.idle_timeout}"

  access_logs = {
    prefix  = "${var.access_logs_prefix}"
    bucket  = "${var.access_logs_bucket}"
    enabled = "true"
  }

  tags = "${merge(var.tags, map("Name", "${local.name_prefix}"))}"
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

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${coalesce(join("",aws_lb.main.*.name), join("", aws_lb.main_with_access_logs.*.name))}"
  count          = "${var.add_cloudwatch_dashboard == "true" ? 1:0}"

  dashboard_body = <<EOF
  {
     "start":"-PT6H",
     "periodOverride":"inherit",
     "widgets":[
       {
         "type":"metric",
         "x":0,
         "y":0,
         "width":4,
         "height":6,
         "properties": {
            "view": "singleValue",
            "metrics": [
                [ "AWS/ApplicationELB", "ActiveConnectionCount", "LoadBalancer",   "${substr(coalesce(join("",aws_lb.main.*.arn), join("", aws_lb.main_with_access_logs.*.arn)),65,-1)}" ]
            ],
            "region": "eu-west-1",
            "period": 360
          }
        },
        {
           "type":"metric",
           "x":5,
           "y":0,
           "width":20,
           "height":6,
           "properties":{
              "title": "Requestcount & Average Responsetime",
              "view":"timeSeries",
              "stacked":false,
              "metrics":[
                 [
                    "AWS/ApplicationELB",
                    "TargetResponseTime",
                    "LoadBalancer",
                    "${substr(coalesce(join("",aws_lb.main.*.arn), join("", aws_lb.main_with_access_logs.*.arn)),65,-1)}"
                 ],
                 [
                    "AWS/ApplicationELB",
                    "RequestCount",
                    "LoadBalancer",
                    "${substr(coalesce(join("",aws_lb.main.*.arn), join("", aws_lb.main_with_access_logs.*.arn)),65,-1)}",
                    {"stat": "Sum"}
                 ]
              ],
              "region":"${data.aws_region.current.name}",
              "period":300
           }
        }
     ]
  }
 EOF
}
