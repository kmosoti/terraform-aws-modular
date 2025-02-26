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

# Clone Salt States Repository into /srv/salt/state if not already present
if [ ! -d "/srv/salt/state" ]; then
  sudo git clone https://github.com/kmosoti/terraform-aws-modular-salt-states.git /srv/salt/state
fi

# Clone Salt Pillars Repository into /srv/salt/pillar if not already present
if [ ! -d "/srv/salt/pillar" ]; then
  sudo git clone https://${pillar_token}@github.com/kmosoti/terraform-aws-modular-salt-pillars.git /srv/salt/pillar
fi

# Clone Salt Reactors Repository into /srv/salt/reactor if not already present
if [ ! -d "/srv/salt/reactor" ]; then
  sudo git clone https://github.com/kmosoti/terraform-aws-modular-salt-reactor.git /srv/salt/reactor
fi

# Configure reactor on the Salt Master by creating the reactor configuration file
sudo tee /etc/salt/master.d/reactor.conf > /dev/null <<EOF
reactor:
  - 'salt/minion/*/start':
    - salt://reactor/minion/on_start.sls
EOF


# Configure file_roots and pillar_roots for Salt Master
sudo mkdir -p /etc/salt/master.d
cat <<EOF | sudo tee /etc/salt/master.d/file_roots.conf
file_roots:
  base:
    - /srv/salt/state/states

pillar_roots:
  base:
    - /srv/salt/pillar/pillars
EOF

# Configure autosign grains directory
sudo mkdir -p /etc/salt/autosign_grains
echo "autosign_grains_dir: /etc/salt/autosign_grains" | sudo tee -a /etc/salt/master.d/autosign.conf

# Loop through the array of minion UUIDs and append each to the autosign file.
%{ for uuid in minion_uuids ~}
echo "${uuid}" | sudo tee -a /etc/salt/autosign_grains/uuid
%{ endfor ~}


# Set ownership and permissions for state and pillar directories
sudo chown -R root:salt /srv/salt/state /srv/salt/pillar
sudo find /srv/salt/state/states/ -type d -exec chmod 755 {} \;
sudo find /srv/salt/state/states/ -type f -exec chmod 644 {} \;
sudo find /srv/salt/pillar/pillars/ -type d -exec chmod 750 {} \;
sudo find /srv/salt/pillar/pillars/ -type f -exec chmod 640 {} \;

# Enable and start Salt Master
sudo systemctl enable salt-master
sudo systemctl start salt-master
