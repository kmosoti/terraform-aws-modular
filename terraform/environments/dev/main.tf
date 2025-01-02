module "network" {
  source      = "../../modules/network"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "sg_salt_minion" {
  source        = "../../modules/security_group"
  vpc_id        = module.network.vpc_id
  ingress_port  = 22
  allowed_cidrs = ["0.0.0.0/0"]
  name          = "test-machine-sg"
}

module "sg_salt_master" {
  source        = "../../modules/security_group"
  vpc_id        = module.network.vpc_id
  ingress_port  = 22
  allowed_cidrs = ["150.221.129.128/32"]
  name          = "test-machine-sg"
  allowed_sg_ids    = [module.sg_salt_minion.security_group_id]
}

module "salt_master" {
  source        = "../../modules/vm"
  instance_type = "t2.micro"
  ami           = "ami-0e2c8caa4b6378d8c"
  key_name      = var.key_name
  subnet_id     = element(module.network.public_subnet_ids, 0)
  minion_name   = "salt-master"
  name          = "salt-master"
  security_group_ids  = [module.sg_salt_master.security_group_id]

  user_data = <<EOT
#!/bin/bash

# Ensure keyrings directory exists
mkdir -p /etc/apt/keyrings

# Download Salt public key
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp

# Create Salt apt repository configuration
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

# Update package lists
sudo apt-get update -y

# Install Salt Master, Git, and UFW
sudo apt-get install -y salt-master git ufw

# Clone States Repository into /srv/salt/state
sudo git clone https://github.com/kmosoti/terraform-aws-modular-salt-states.git /srv/salt/state

# Clone Pillars Repository into /srv/salt/pillar
sudo git clone https://github.com/kmosoti/terraform-aws-modular-salt-pillars.git /srv/salt/pillar

# Configure file_roots and pillar_roots
sudo mkdir -p /etc/salt/master.d
cat <<EOF | sudo tee /etc/salt/master.d/file_roots.conf
file_roots:
  base:
    - /srv/salt/state/states

pillar_roots:
  base:
    - /srv/salt/pillar/pillars
EOF

# Configure auto_accept in auth.conf
cat <<EOF | sudo tee /etc/salt/master.d/auth.conf
auto_accept: True
EOF

# Set ownership
sudo chown -R root:salt /srv/salt/state /srv/salt/pillar

# Set permissions for states
sudo find /srv/salt/state/states/ -type d -exec chmod 755 {} \;
sudo find /srv/salt/state/states/ -type f -exec chmod 644 {} \;

# Set permissions for pillars
sudo find /srv/salt/pillar/pillars/ -type d -exec chmod 750 {} \;
sudo find /srv/salt/pillar/pillars/ -type f -exec chmod 640 {} \;

# Enable and start Salt Master
sudo systemctl enable salt-master
sudo systemctl start salt-master

EOT
}

module "test_machine" {
  source        = "../../modules/vm"
  instance_type = "t2.micro"
  ami           = "ami-0e2c8caa4b6378d8c"
  key_name      = var.key_name
  subnet_id     = element(module.network.public_subnet_ids, 1)
  salt_master_ip = module.salt_master.private_ip
  minion_name   = "test-machine-minion"
  name          = "test-machine-minion"
  security_group_ids  = [module.sg_salt_minion.security_group_id]

  user_data = <<EOT
#!/bin/bash

# Ensure keyrings dir exists
mkdir -p /etc/apt/keyrings
# Download public key
curl -fsSL https://packages.broadcom.com/artifactory/api/security/keypair/SaltProjectKey/public | sudo tee /etc/apt/keyrings/salt-archive-keyring.pgp
# Create apt repo target configuration
curl -fsSL https://github.com/saltstack/salt-install-guide/releases/latest/download/salt.sources | sudo tee /etc/apt/sources.list.d/salt.sources

# Update the system and install Salt minion
sudo apt-get update -y
sudo apt-get install -y salt-minion

# Configure Salt Minion to connect to the Salt Master
echo "master: ${module.salt_master.private_ip}" | sudo tee /etc/salt/minion.d/master.conf
echo "id: test-machine-minion" | sudo tee /etc/salt/minion.d/id.conf

# Enable and start Salt Minion
sudo systemctl enable salt-minion
sudo systemctl stop salt-minion
sudo systemctl start salt-minion
EOT
}

output "salt_master_private_ip" {
  value = module.salt_master.private_ip
}

output "salt_master_public_ip" {
  value = module.salt_master.public_ip
}
