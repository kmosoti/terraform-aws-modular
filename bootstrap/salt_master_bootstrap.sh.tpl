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

# Configure auto-accept grains directory
sudo mkdir -p /etc/salt/autosign_grains
echo "autosign_grains_dir: /etc/salt/autosign_grains" | sudo tee -a /etc/salt/master.d/autosign.conf

# Create a UUID file for auto-accepting minions
echo "${uuid}" | sudo tee /etc/salt/autosign_grains/uuid
echo "${discord_bot_uuid}" | sudo tee /etc/salt/autosign_grains/uuid

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
