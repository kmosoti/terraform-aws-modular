variable "aws_region" {
  description = "AWS region to deploy resources"
  default     = "us-east-1"
}

variable "key_name" {
  description = "Key pair for SSH access"
  default     = "terraform-project-key"
}

variable "salt_master_ip" {
  description = "Public IP address of the Salt Master"
  default     = "0.0.0.0" # Replace with your actual Salt Master IP
}

variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "us-east-1"  # Change to your preferred region
}
