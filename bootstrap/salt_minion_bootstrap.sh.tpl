#!/bin/bash
# Minimal Salt Minion Bootstrap Script

# Update package lists and install Salt Minion
sudo apt-get update -y
sudo apt-get install -y salt-minion

# Optionally, upgrade salt-minion (recommended)
sudo apt-get upgrade -y salt-minion

# Configure the Salt Minion to connect to the Salt Master:
echo "master: ${salt_master_private_ip}" | sudo tee /etc/salt/minion.d/master.conf

# Set the minion ID (ensure you pass "dave-discord-bot" for the Discord bot)
echo "id: ${minion_name}" | sudo tee /etc/salt/minion.d/id.conf

# Write the unique identifier (UUID) as a grain for autosigning
cat <<EOF | sudo tee /etc/salt/grains
uuid: ${uuid}
EOF

# Instruct the minion to send the 'uuid' grain at key-sign time for automatic acceptance
cat <<EOF | sudo tee /etc/salt/minion.d/autosign.conf
autosign_grains:
  - uuid
EOF

# Enable and restart the Salt Minion to apply the configuration
sudo systemctl enable salt-minion
sudo systemctl restart salt-minion