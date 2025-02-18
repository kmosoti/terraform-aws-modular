variable "vpc_id" {
  description = "The VPC ID to attach the security group to"
  type        = string
}

variable "name" {
  description = "Name of the security group"
  type        = string
}

variable "ingress_rules" {
  description = <<-EOF
List of ingress rule objects. Each rule object should include:
  - from_port (number)
  - to_port (number)
  - protocol (string)
  - cidr_blocks (list(string))
  - sg_ids (optional, list(string)) for referencing other security groups
  - description (optional, string)
EOF
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    sg_ids      = optional(list(string), [])
    description = optional(string)
  }))
  default = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
  ]
}

variable "egress_rules" {
  description = <<-EOF
List of egress rule objects. Each rule object should include:
  - from_port (number)
  - to_port (number)
  - protocol (string)
  - cidr_blocks (list(string))
  - description (optional, string)
EOF
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = optional(string)
  }))
  default = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      description = "Allow all outbound traffic"
    }
  ]
}

variable "allowed_sg_ids" {
  description = "List of security group IDs to allow ingress from salt hosts"
  type        = list(string)
  default     = []
}

variable "allowed_cidrs" {
  description = "List of CIDR blocks to allow ingress from"
  type        = list(string)
  default     = []
}
