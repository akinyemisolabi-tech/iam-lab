# Find Amazon Linux 2023 AMI (must use data - AMIs are Amazon's images)
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# Security Group - Firewall for EC2
resource "aws_security_group" "ec2_sg" {
  name        = "iam-lab-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "iam-lab-sg"
  }
}

# EC2 Instance
resource "aws_instance" "test_server" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  key_name               = "ASAWSKeyPair"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "iam-lab-instance"
  }
}

# Output the public IP
output "instance_public_ip" {
  value = aws_instance.test_server.public_ip
}

output "ssh_command" {
  value = "ssh -i ~/Downloads/ASAWSKeyPair.pem ec2-user@${aws_instance.test_server.public_ip}"
}
