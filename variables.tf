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
  description = "A list of subnet IDs to attach to the LB."
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

variable "access_logs" {
  description = "An Access Logs block."
  type        = map(string)
  default     = {}
}

variable "idle_timeout" {
  description = "(Optional) The time in seconds that the connection is allowed to be idle. Only valid for Load Balancers of type application."
  type        = number
  default     = 60
}

variable "tags" {
  description = "A map of tags (key-value pairs) passed to resources."
  type        = map(string)
  default     = {}
}

variable "ip_address_type" {
  description = "The type of IP addresses used by the subnets for your load balancer. The possible values are \"ipv4\" and \"dualstack\"."
  type        = string
  default     = "ipv4"
}
