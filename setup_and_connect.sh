#!/bin/bash

# Ensure the script stops on errors
set -e

# Function to check if a command is installed
check_command() {
    if ! command -v "$1" &>/dev/null; then
        return 1
    fi
    return 0
}

# Function to install Terraform
install_terraform() {
    echo "Installing Terraform..."
    wget -qO- https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip -O terraform.zip
    unzip -o terraform.zip -d /usr/local/bin/
    rm -f terraform.zip
    echo "Terraform installed successfully."
}

# Function to install AWS CLI
install_aws_cli() {
    echo "Installing AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf awscliv2.zip aws
    echo "AWS CLI installed successfully."
}

# Step 1: Check and install Terraform if needed
if ! check_command terraform; then
    install_terraform
else
    echo "Terraform is already installed."
fi

# Step 2: Check and install AWS CLI if needed
if ! check_command aws; then
    install_aws_cli
else
    echo "AWS CLI is already installed."
fi

# Step 3: Verify AWS credentials
echo "Checking AWS CLI configuration..."
if ! aws sts get-caller-identity &>/dev/null; then
    echo "AWS CLI is not configured. Please run 'aws configure' to set up your credentials."
    exit 1
fi
echo "AWS CLI is configured and ready."

# Step 4: Run the Terraform script
echo "Running Terraform to set up the environment..."
chmod +x deploy-kali
./deploy-kali

# Step 5: Run the post-deployment script to configure the instance
echo "Running the post-deployment script to configure the instance..."
chmod +x kaliattack.sh
./kaliattack.sh

# Step 6: Provide connection details
echo "Terraform environment and instance configuration are complete."
INSTANCE_IP=$(terraform output -raw kali_instance_eip)
echo "You can now connect to your instance with:"
echo "ssh -i ./kali_auto_key.pem kali@$INSTANCE_IP"


