# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------
output "arn" {
  description = "The ARN of the load balancer."
  value       = concat(aws_lb.main[*].arn, aws_lb.main_with_access_logs[*].arn, [""])[0]
}

output "name" {
  description = "The name of the load balancer."
  value       = element(split("/", concat(aws_lb.main[*].name, aws_lb.main_with_access_logs[*].name, [""])[0]), 2)
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = concat(aws_lb.main[*].dns_name, aws_lb.main_with_access_logs[*].dns_name, [""])[0]
}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = concat(aws_lb.main[*].zone_id, aws_lb.main_with_access_logs[*].zone_id, [""])[0]
}

output "origin_id" {
  description = "First part of the DNS name of the load balancer."
  value       = element(split(".", concat(aws_lb.main[*].dns_name, aws_lb.main_with_access_logs[*].dns_name, [""])[0]), 0)
}

output "security_group_id" {
  description = "The ID of the security group."
  value       = concat(aws_security_group.main[*].id, [""])[0]
}

output "access_logs_s3_bucket_arn" {
  description = "The arn of the S3 bucket logs are written to. Empty if log_access is false."
  value       = concat(aws_s3_bucket.elb_logs[*].arn, [""])[0]
}

