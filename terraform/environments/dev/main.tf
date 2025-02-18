module "network" {
  source      = "../../modules/network"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "sg_salt_minion" {
  source        = "../../modules/security_group"
  vpc_id        = module.network.vpc_id
  allowed_cidrs = ["0.0.0.0/0"]
  name          = "salt-minion-sg"
}

module "sg_salt_master" {
  source         = "../../modules/security_group"
  vpc_id         = module.network.vpc_id
  allowed_cidrs  = ["150.221.129.128/32"]
  name           = "salt-master-sg"
}
resource "aws_security_group_rule" "allow_salt_minion_to_master" {
  type                     = "ingress"
  from_port                = 4505
  to_port                  = 4506
  protocol                 = "tcp"
  security_group_id        = module.sg_salt_master.security_group_id
  source_security_group_id = module.sg_salt_minion.security_group_id
  description              = "Allow Salt Minions to communicate with Salt Master"
}

resource "aws_security_group_rule" "allow_salt_master_to_minion" {
  type                     = "ingress"
  from_port                = 4505
  to_port                  = 4506
  protocol                 = "tcp"
  security_group_id        = module.sg_salt_minion.security_group_id
  source_security_group_id = module.sg_salt_master.security_group_id
  description              = "Allow Salt Master to communicate with Minions"
}



module "sg_discord_bot" {
  source        = "../../modules/security_group"
  vpc_id        = module.network.vpc_id
  name          = "discord-bot-sg"
  allowed_cidrs = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "discord_bot_https" {
  
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = module.sg_discord_bot.security_group_id
}


# Generate an array of minion UUIDs (defined in terraform.tfvars)
module "salt_master_module" {
  source              = "../../modules/salt_master_module"
  instance_type       = "t3.micro"
  key_name            = var.key_name
  subnet_id           = element(module.network.public_subnet_ids, 0)
  security_group_ids  = [module.sg_salt_master.security_group_id]
  name                = "salt-master"
  minion_uuids        = var.minion_uuids
}

module "discord_bot_minion_module" {
  source                 = "../../modules/salt_minion_module"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = element(module.network.private_subnet_ids, 0)
  security_group_ids     = [module.sg_salt_minion.security_group_id, module.sg_discord_bot.security_group_id]
  salt_master_private_ip = module.salt_master_module.private_ip
  minion_name            = "discord-bot"
  name                   = "discord-bot"
  minion_guid            = var.minion_guid
}

output "salt_master_public_ip" {
  description = "Public IP address of the Salt Master\n Use this to SSH into the Salt Master:" 
  value       = "IP:${module.salt_master_module.public_ip}\nCONNECT: ssh -i terraform-project-key.pem ubuntu@${module.salt_master_module.public_ip}"
}
