resource "aws_instance" "vm" {
  ami                    = var.ami
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.security_group_ids
  associate_public_ip_address = true

  # User data for bootstrapping the Salt Minion
  user_data = var.user_data

  tags = {
    Name = var.name
  }
}