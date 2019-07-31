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

variable "access_logs_bucket" {
  description = "Bucket for ELB access logs."
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

