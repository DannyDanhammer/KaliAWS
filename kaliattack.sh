#!/bin/bash

# Load variables
PRIVATE_KEY_PATH="./kali_auto_key.pem"
INSTANCE_IP=$(terraform output -raw kali_instance_eip)

# Validate variables
if [[ -z "$INSTANCE_IP" || ! -f "$PRIVATE_KEY_PATH" ]]; then
  echo "Error: Instance IP or private key not found. Run 'deploy-kali' first."
  exit 1
fi

# Ensure private key has correct permissions
chmod 400 "$PRIVATE_KEY_PATH"

# Enable root login and set root password via SSH
echo "Configuring Kali instance at $INSTANCE_IP..."
ssh -i "$PRIVATE_KEY_PATH" -o StrictHostKeyChecking=no ubuntu@$INSTANCE_IP << 'EOF'
  sudo -s
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
  service sshd restart
  echo "kali:kali" | chpasswd
  apt update
  apt install -y kali-linux-full
  exit
EOF

echo "Configuration complete. You can now log in as root:"
echo "ssh -i $PRIVATE_KEY_PATH kali@$INSTANCE_IP"

# Wait for the instance to become SSH-ready
echo "Waiting for SSH to be available at $INSTANCE_IP..."
for i in {1..30}; do
    if ssh -o BatchMode=yes -o ConnectTimeout=5 -i "$PRIVATE_KEY_PATH" kali@$INSTANCE_IP "echo 'Instance is ready'" 2>/dev/null; then
        echo "Instance is ready for SSH."
        break
    else
        echo "Attempt $i: SSH not ready yet. Retrying in 5 seconds..."
        sleep 5
    fi

    if [[ $i -eq 30 ]]; then
        echo "Error: SSH connection could not be established after 30 attempts."
        exit 1
    fi
done
echo "ssh -i $PRIVATE_KEY_PATH kali@$INSTANCE_IP"

ssh -i $PRIVATE_KEY_PATH kali@$INSTANCE_IP
