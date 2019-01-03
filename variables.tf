# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "A prefix used for naming resources."
}

variable "vpc_id" {
  description = "The VPC ID."
}

variable "log_access" {
  description = "Log access to S3. Defaults to false"
  default     = "false"
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

variable "idle_timeout" {
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  default     = 60
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = "map"
  default     = {}
}
