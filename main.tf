provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

# Generate an SSH key pair
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = "kali-auto-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Define the Security Group
resource "aws_security_group" "kali_sg" {
  name        = "kali-server-sg"
  description = "Allow SSH, HTTPS, HTTP-ALT, custom traffic, and all outbound"

  # Allow SSH (port 22)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS (port 443)
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP-ALT (port 8080)
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow custom traffic (port 6000)
  ingress {
    from_port   = 6000
    to_port     = 6000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Launch the EC2 instance for Kali
resource "aws_instance" "kali_instance" {
  ami           = "ami-061b17d332829ab1c"  # Replace with a valid Kali Linux AMI ID
  instance_type = "t2.micro"

  security_groups = [aws_security_group.kali_sg.name]
  key_name        = aws_key_pair.generated_key.key_name

  tags = {
    Name = "kali-instance"
  }
}

# Create an Elastic IP
resource "aws_eip" "kali_eip" {
  instance = aws_instance.kali_instance.id
  tags = {
    Name = "kali-eip"
  }
}

# Save the private key locally
resource "local_file" "private_key" {
  content  = tls_private_key.ssh_key.private_key_pem
  filename = "${path.module}/kali_auto_key.pem"
}

# Output the Elastic IP
output "kali_instance_eip" {
  value = aws_eip.kali_eip.public_ip
}

# Output the private key path
output "private_key_path" {
  value = local_file.private_key.filename
}
