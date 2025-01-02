variable "ami" {
  description = "Amazon Machine Image ID"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "salt_master_ip" {
  description = "Public IP address of the Salt Master"
  type        = string
  default     = "" # Optional: Default to empty for Salt Master to self-configure
}

variable "minion_name" {
  description = "Unique name for the Salt Minion"
  type        = string
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "user_data" {
  type        = string
  description = "User data script for EC2 instance."
  default     = <<-EOT
#!/bin/bash
# Placeholder / default user_data.
# This runs if no custom user_data is provided.
echo "No custom user_data specified."
EOT
}

variable "security_group_ids" {
  type        = list(string)
  description = "List of security group IDs to attach to the EC2 instance"
  default     = []
}
