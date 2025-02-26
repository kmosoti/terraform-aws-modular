# Terraform AWS Modular Setup

This repository contains a modular Terraform configuration for deploying infrastructure on AWS. It uses separate modules for networking, security groups, and EC2 instances, and leverages SaltStack for configuration management. The Salt Master and minion (for our Discord bot) are provisioned and bootstrapped automatically.

## Project Structure

```
terraform-aws-modular/
│   .gitignore
│   README.md
│
├── bootstrap/                 # Bootstrapping scripts for EC2 instances
│   ├── discord_bot_bootstrap.sh.tp1
│   ├── dynamodb_statelock_bootstrap.ps1
│   ├── salt_master_bootstrap.sh.tpl
│   └── salt_minion_bootstrap.sh.tpl
│
└── terraform/                 # Core Terraform configuration
    ├── backend.tf             # Remote backend configuration
    ├── outputs.tf             # Outputs for infrastructure
    ├── provider.tf            # AWS provider configuration
    ├── variables.tf           # Global variables
    ├── environments/          # Environment-specific configs
    │   ├── dev/               # Development environment
    │   └── prod/              # Production environment
    └── modules/               # Modular components
        ├── network/           # VPC, subnets, routes
        ├── salt_master_module/# Salt Master instance setup
        ├── salt_minion_module/# Salt Minion instance setup (for Discord bot)
        ├── security_group/    # Security group definitions
        └── vm/                # Generic VM module
```

## Features

- **Modular Architecture:**  
  Separate modules for networking, security groups, Salt Master, and Salt minions allow for reusable, maintainable code.

- **SaltStack Integration:**  
  The Salt Master and minions are automatically bootstrapped using custom scripts. Minions are autosigned based on a list of UUIDs, and the Discord bot code is deployed via a Git repository.

- **Environment Specifics:**  
  Environment configurations (e.g., dev and prod) are managed in the `environments/` folder. Each environment has its own `terraform.tfvars` file for customizing settings like CIDR blocks and instance types.

- **Security and Cost Management:**  
  The project leverages AWS security groups to control access and allows you to run your minions (which host your apps) 24/7, while the Salt Master can be stopped when not in use to save on costs.

## Usage

1. **Initialize Terraform:**  
   Navigate to the environment directory and run:
   ```bash
   cd terraform/environments/dev
   terraform init
   ```

2. **Plan Your Deployment:**  
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```

3. **Apply the Configuration:**  
   ```bash
   terraform apply -var-file=terraform.tfvars --auto-approve
   ```

4. **Destroy Infrastructure (if needed):**  
   ```bash
   terraform destroy -var-file=terraform.tfvars --auto-approve
   ```
git 
## SaltStack States and Pillars

The Salt states are stored in a separate repository. You can view the public [Salt States Repository](https://github.com/kmosoti/terraform-aws-modular-salt-states) for details on how the states are structured and applied.

For sensitive configuration such as the Discord bot token, we use a private Salt Pillars repository. Because this configuration is private, please refer to the official [Salt Pillars documentation](https://docs.saltproject.io/en/latest/topics/pillar/index.html) for guidance on setting up and securing your pillar data.

## Additional Information

- **Network & Security:**  
  The networking module creates public and private subnets, attaches an Internet Gateway and a NAT Gateway (for private subnets), and manages routing. Security groups are defined in a separate module with default rules (SSH, Salt ports, etc.) plus additional custom rules where needed.

- **Bootstrapping:**  
  Custom bootstrap scripts under the `bootstrap/` directory handle the initial installation of Salt Master/Minion and other necessary components (such as Python virtual environments and Git).

- **Cost Management:**  
  The architecture is designed so that critical apps on minions run 24/7, while the Salt Master can be shut down when not actively updating configurations.