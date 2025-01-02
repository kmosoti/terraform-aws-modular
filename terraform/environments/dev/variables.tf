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
