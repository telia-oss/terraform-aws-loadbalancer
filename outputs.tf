# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "arn" {
  description = "The ARN of the load balancer."
  value       = "${coalesce(join("",aws_lb.main.*.arn), join("", aws_lb.main_with_access_logs.*.arn))}"
}

output "name" {
  description = "The name of the load balancer."
  value       = "${element(split("/", coalesce(join("",aws_lb.main.*.name),  join("", aws_lb.main_with_access_logs.*.name))),2)}"
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = "${coalesce(join("",aws_lb.main.*.dns_name), join("", aws_lb.main_with_access_logs.*.dns_name))}"
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = "${coalesce(join("",aws_lb.main.*.zone_id), join("", aws_lb.main_with_access_logs.*.zone_id))}"
}

output "origin_id" {
  description = "First part of the DNS name of the load balancer."
  value       = "${element(split(".", coalesce(join("",aws_lb.main.*.dns_name), join("", aws_lb.main_with_access_logs.*.dns_name))),0)}"
}

output "security_group_id" {
  description = "The ID of the security group."
  value       = "${element(concat(aws_security_group.main.*.id, list("")), 0)}"
}

output "access_logs_s3_bucket_arn" {
  description = "The arn of the S3 bucket logs are written to. Empty if log_access set to \"false\""
  value = "${aws_s3_bucket.elb_logs.*.arn}"
}