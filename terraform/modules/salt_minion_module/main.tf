resource "aws_instance" "vm" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = false

  # User data should bootstrap the Salt minion – it must configure:
  #   - The connection to the Salt Master
  #   - The minion ID (e.g., "dave-discord-bot")
  #   - The grain containing the unique UUID for autosigning
  user_data = templatefile("${path.module}/salt_minion_bootstrap.sh.tpl", {
    uuid = var.minion_guid
    salt_master_private_ip = var.salt_master_private_ip
    minion_name = var.minion_name
  })

  tags = {
    Name = var.name
  }
}
