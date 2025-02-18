variable "salt_master_ip" {
  description = "The public IP address of the Salt Master"
  type        = string
  default     = "0.0.0.0" # Replace with the actual Salt Master IP if available
}

variable "key_name" {
  description = "The name of the SSH key pair to use for EC2 instances"
  type        = string
  default     = "my-key-pair" # Replace with your actual key pair name
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"  # Change to your preferred region
}

variable "minion_uuids" {
  description = "List of minion UUIDs for autosigning minions"
  type = list(string)
  default = []  # Replace with your desired default or remove default to require input
}

variable "minion_guid" {
  description = "The GUID for the minion"
  type        = string
}