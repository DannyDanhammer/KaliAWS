KaliAWS

A Terraform script to spin up Kali Linux instances and tear them down on AWS.
Overview

This project automates the creation of a Kali Linux EC2 instance on AWS using Terraform. It also provides tools to automatically configure your system, connect to the instance, and clean up resources when you're finished.
Setup
1. Clone the Repository

Download or clone the repository to your local machine.
2. Prepare Your Environment

Place all files in the same directory and make them executable:

chmod +x *.sh

3. Obtain Your AWS Keys

    Get your AWS Access Key ID and AWS Secret Access Key from the AWS Management Console.
    Ensure these credentials are available in your AWS CLI configuration or provide them during setup.
   For instructions see Apdx 1

5. Run the Setup Script

Run the setup_and_connect.sh script to prepare your environment:

./setup_and_connect.sh

Script Workflow

    Environment Setup:
        Installs AWS CLI and Terraform if not already installed.
        Validates AWS credentials (prompts for them if necessary).
        Configures the region (default: us-east-1). You can change this in the script or main.tf.

    Kali Instance Deployment:
        Generates SSH key pairs for secure access.
        Provisions a Kali Linux EC2 instance with an Elastic IP.
        Default open ports (defined in main.tf):
            22 (SSH)
            443 (HTTPS)
            8080 (HTTP-ALT)
            6000 (custom traffic)
        Allows all outbound traffic by default.

    Automatic SSH Login:
        After setup, the script attempts to log in to the instance automatically using:

    ssh -i ./kali_auto_key.pem kali@<instance-ip>

    If prompted, type yes to accept the SSH host key on the first login.

Reconnect with kaliattack.sh:

    If disconnected, run:

    ./kaliattack.sh

    This reconnects you to the Kali instance automatically.

Tear Down Resources:

    When finished, run the decommissioning script:

        ./decom.sh

        This destroys all AWS resources created during deployment.

![image](https://github.com/user-attachments/assets/9d377c13-f9e1-47ff-b008-7dab5a7605e0)


To change the AWS region:

    Update the region in main.tf:

    provider "aws" {
      region = "your-preferred-region"
    }

    Update the region in the AWS CLI or during setup when prompted.

Adding/Removing Ports

Modify the aws_security_group block in main.tf to add or remove ports:

ingress {
  from_port   = <port-number>
  to_port     = <port-number>
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

Troubleshooting

    SSH Connection Issues:
        If the script fails to log in automatically, it will provide the instance IP and a manual SSH command. Use:

    ssh -i ./kali_auto_key.pem kali@<instance-ip>

Invalid AWS Credentials:

    Ensure your AWS keys are correctly configured. You can manually configure them using:

        aws configure

    Instance Not Ready:
        If the instance isn’t accessible immediately, the setup script will retry until SSH is available.

Example Usage

    Deploy Instance:

./setup_and_connect.sh

Reconnect to Instance:

./kaliattack.sh

Tear Down Resources:

    ./decom.sh

Requirements

    Operating System: Linux
    Dependencies: AWS CLI, Terraform
    AWS Account: With permissions to create EC2 instances, Elastic IPs, and security groups.

License

This project is open-source under the MIT License.



APDX 1
Downloading and Installing AWS CLI on Windows and Linux
On Windows

    Download the Installer:
        Go to the AWS CLI version 2 download page for Windows.
        Download the .msi installer.

    Run the Installer:
        Double-click the downloaded .msi file.
        Follow the on-screen instructions to complete the installation.

    Verify the Installation:
        Open Command Prompt or PowerShell and type:

        aws --version

        It should return the installed version of AWS CLI.

    Add AWS CLI to Path (if needed):
        If aws is not recognized, ensure the installation directory (e.g., C:\Program Files\Amazon\AWSCLIV2\) is in your system's PATH environment variable.

On Linux

    Download the Installer:
        Open a terminal and run:

    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

Extract the Files:

    Use unzip to extract the downloaded archive:

    unzip awscliv2.zip

Install AWS CLI:

    Run the installer as a superuser:

    sudo ./aws/install

Verify the Installation:

    Check if the AWS CLI is installed:

    aws --version

    You should see the version number.

Optional Cleanup:

    Remove the downloaded files to save space:

        rm -rf awscliv2.zip aws

Post-Installation Steps

    Set Up AWS Credentials: After installing, configure AWS CLI with your credentials:

aws configure
