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
echo "id: salt-minion-1" | sudo tee /etc/salt/minion.d/id.conf

# Enable and start Salt Minion
sudo systemctl enable salt-minion
sudo systemctl stop salt-minion
sudo systemctl start salt-minion