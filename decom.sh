#!/bin/bash

# Ensure the script stops on errors
set -e

# Navigate to the Terraform directory
# Replace <your-terraform-directory> with the directory where your Terraform files are located
 

echo "Starting Terraform Decommission Process..."

# Initialize Terraform if necessary
terraform init -reconfigure

# Destroy all Terraform-managed resources
echo "Destroying all Terraform-managed resources..."
terraform destroy -auto-approve

# Check for remaining Elastic IPs and release them
echo "Checking for remaining Elastic IPs..."
EIP_ALLOCATION_IDS=$(aws ec2 describe-addresses --query "Addresses[*].AllocationId" --output text)
if [ -n "$EIP_ALLOCATION_IDS" ]; then
    echo "Found Elastic IPs. Releasing them..."
    for ALLOCATION_ID in $EIP_ALLOCATION_IDS; do
        echo "Releasing Elastic IP with Allocation ID: $ALLOCATION_ID"
        aws ec2 release-address --allocation-id "$ALLOCATION_ID"
    done
else
    echo "No remaining Elastic IPs found."
fi

# Verify all resources are decommissioned
echo "Verifying that all resources have been decommissioned..."

# Check for remaining EC2 instances
INSTANCE_IDS=$(aws ec2 describe-instances --query "Reservations[*].Instances[*].InstanceId" --output text)
if [ -n "$INSTANCE_IDS" ]; then
    echo "WARNING: The following EC2 instances are still running:"
    echo "$INSTANCE_IDS"
else
    echo "No remaining EC2 instances found."
fi

# Check for remaining Security Groups
SECURITY_GROUP_IDS=$(aws ec2 describe-security-groups --query "SecurityGroups[*].GroupId" --output text)
if [ -n "$SECURITY_GROUP_IDS" ]; then
    echo "WARNING: The following Security Groups still exist:"
    echo "$SECURITY_GROUP_IDS"
else
    echo "No remaining Security Groups found."
fi

echo "Terraform Decommission Process Completed."
