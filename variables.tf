# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "A prefix used for naming resources."
}

variable "vpc_id" {
  description = "The VPC ID."
}

variable "subnet_ids" {
  description = "ID of subnets where instances can be provisioned."
  type        = "list"
}

variable "type" {
  description = "Type of load balancer to provision (network or application)."
}

variable "internal" {
  description = "Provision an internal load balancer. Defaults to false."
  default     = "false"
}

variable "access_logs_prefix" {
  description = "Prefix for access log bucket items."
  default     = ""
}

variable "access_logs_bucket" {
  description = "Bucket for ELB access logs."
  default     = ""
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = "map"
  default     = {}
}
