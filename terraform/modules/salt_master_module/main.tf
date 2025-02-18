locals {
  pillar_token = chomp(file("${path.module}/token.txt"))
}


resource "aws_instance" "master" {
  ami                         = var.ami
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  key_name                    = var.key_name
  vpc_security_group_ids      = var.security_group_ids
  associate_public_ip_address = true

  user_data = templatefile("${path.module}/salt_master_bootstrap.sh.tpl", {
    pillar_token = local.pillar_token,
    minion_uuids = var.minion_uuids
  })

  tags = {
    Name = var.name
  }
}
