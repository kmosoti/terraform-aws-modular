variable "ami" {
  description = "Amazon Machine Image ID for Salt Master"
  type        = string
  default     = "ami-0e2c8caa4b6378d8c"
}

variable "instance_type" {
  description = "EC2 instance type for the Salt Master"
  type        = string
  default     = "t3.micro"
}

variable "subnet_id" {
  description = "Subnet ID to launch the Salt Master in (should have public IP)"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the Salt Master instance"
  type        = list(string)
  default     = []
}

variable "name" {
  description = "Name tag for the Salt Master instance"
  type        = string
}

variable "minion_uuids" {
  description = "List of minion UUIDs for autosigning minions"
  type        = list(string)
  default     = []  # You can override this from your environment.
}

variable "user_data" {
  description = "User data script to bootstrap the Salt Master"
  type        = string
  default     = <<-EOT
    #!/bin/bash
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
      sudo git clone https://github.com/kmosoti/terraform-aws-modular-salt-pillars.git /srv/salt/pillar
    fi
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
    # Configure autosign directory (ensure minions with the proper grain or ID are auto-accepted)
    sudo mkdir -p /etc/salt/autosign_grains
    echo "autosign_grains_dir: /etc/salt/autosign_grains" | sudo tee -a /etc/salt/master.d/autosign.conf
    # (Optional) Create autosign file for minion ID if desired:
    # echo "dave-discord-bot" | sudo tee /etc/salt/autosign
    # Set ownership and permissions for state and pillar directories
    sudo chown -R root:salt /srv/salt/state /srv/salt/pillar
    sudo find /srv/salt/state/states/ -type d -exec chmod 755 {} \;
    sudo find /srv/salt/state/states/ -type f -exec chmod 644 {} \;
    sudo find /srv/salt/pillar/pillars/ -type d -exec chmod 750 {} \;
    sudo find /srv/salt/pillar/pillars/ -type f -exec chmod 640 {} \;
    # Enable and start Salt Master
    sudo systemctl enable salt-master
    sudo systemctl start salt-master
    EOT
}
