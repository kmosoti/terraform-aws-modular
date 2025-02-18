variable "ami" {
  description = "Amazon Machine Image ID for Salt Minion"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance in"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

# Use this variable to pass the Salt Master's IP (typically the private IP)
variable "salt_master_private_ip" {
  description = "Private IP address of the Salt Master"
  type        = string
}

variable "minion_name" {
  description = "Unique name for the Salt Minion (e.g. 'dave-discord-bot')"
  type        = string
}

variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default = "salt-minion"
}

# This variable will hold your Salt minion bootstrap script.
variable "user_data" {
  description = "User data script for bootstrapping the Salt minion"
  type        = string
  default     = <<-EOT
    #!/bin/bash
    sudo apt-get update -y
    sudo apt-get install -y salt-minion
    sudo apt-get upgrade -y salt-minion
    echo "master: salt" | sudo tee /etc/salt/minion.d/master.conf
    echo "id: salt-minion" | sudo tee /etc/salt/minion.d/id.conf
    cat <<EOF | sudo tee /etc/salt/grains
    uuid:
    EOF
    cat <<EOF | sudo tee /etc/salt/minion.d/autosign.conf
    autosign_grains:
      - uuid
    EOF
    sudo systemctl enable salt-minion
    sudo systemctl restart salt-minion
  EOT
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instance"
  type        = list(string)
  default     = []
}

# This is the unique UUID to be written as a grain for autosigning.
# You can generate this using Terraform's random_uuid resource in your environment.
variable "minion_guid" {
  description = "Unique UUID for autosigning this Salt minion"
  type        = string
}
