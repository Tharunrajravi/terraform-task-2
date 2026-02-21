terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

provider "aws" {
  alias  = "us"
  region = "us-east-1"
}

resource "aws_security_group" "mumbai_sg" {
  name = "nginx-sg-mumbai"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "virginia_sg" {
  provider = aws.us
  name     = "nginx-sg-virginia"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu_mumbai" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_virginia" {
  provider    = aws.us
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

locals {
  nginx_script = <<-EOF
              #!/bin/bash
              apt update -y
              apt install nginx -y
              systemctl start nginx
              systemctl enable nginx
              echo "<h1>Server from Terraform</h1>" > /var/www/html/index.html
              EOF
}

resource "aws_instance" "mumbai_ec2" {
  ami                         = data.aws_ami.ubuntu_mumbai.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.mumbai_sg.id]
  associate_public_ip_address = true
  user_data                   = local.nginx_script

  tags = {
    Name = "Mumbai-Nginx"
  }
}

resource "aws_instance" "virginia_ec2" {
  provider                    = aws.us
  ami                         = data.aws_ami.ubuntu_virginia.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.virginia_sg.id]
  associate_public_ip_address = true
  user_data                   = local.nginx_script

  tags = {
    Name = "Virginia-Nginx"
  }
}

output "Mumbai_Public_IP" {
  value = aws_instance.mumbai_ec2.public_ip
}

output "Virginia_Public_IP" {
  value = aws_instance.virginia_ec2.public_ip
}
