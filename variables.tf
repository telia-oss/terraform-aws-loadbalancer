# ------------------------------------------------------------------------------
# Variables
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "A prefix used for naming resources."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID."
  type        = string
}

variable "log_access" {
  description = "Log access to S3. Defaults to false"
  type        = bool
  default     = false
}

variable "subnet_ids" {
  description = "ID of subnets where instances can be provisioned."
  type        = list(string)
}

variable "type" {
  description = "Type of load balancer to provision (network or application)."
  type        = string
}

variable "internal" {
  description = "Provision an internal load balancer. Defaults to false."
  type        = bool
  default     = false
}

variable "access_logs_prefix" {
  description = "Prefix for access log bucket items."
  type        = string
  default     = ""
}

variable "idle_timeout" {
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application. Default: 60."
  type        = number
  default     = 60
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "add_cloudwatch_dashboard" {
  description = "If true, add a cloudwatch dashboard with metrics for the loadbalancer"
  type        = bool
  default     = false
}

