variable "vpc_id" {
  description = "The VPC ID to attach the security group to"
  type        = string
}

variable "ingress_port" {
  description = "Port to allow ingress traffic on"
  type        = number
}

variable "protocol" {
  description = "Protocol for the security group"
  type        = string
  default     = "tcp"
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks for ingress"
  type        = list(string)
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "allowed_sg_ids" {
  type        = list(string)
  description = "Security group IDs allowed to connect (for Salt ports)"
  default     = []
}

