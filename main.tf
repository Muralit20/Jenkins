variable "instance_count" {
  default = 1
}

variable "key_name" {
  description = "Private key name to use with instance"
  default     = "Master-01"
}

variable "instance_type" {
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "ami" {
  description = "Centos7"
  default = "ami-0ec225b5e01ccb706"
}
provider "aws" {
  region = "ap-southeast-1"
}

# Create EC2 instance
resource "aws_instance" "default" {
  ami                    = var.ami
  count                  = var.instance_count
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.default.id]
  source_dest_check      = false
  instance_type          = var.instance_type
  user_data              = <<-EOF
                           #! /bin/bash
                           sudo yum update -y
                           sudo amazon-linux-extras install docker -y
                           sudo service docker start
                           sudo usermod -a -G docker ec2-user
                           EOF
  tags = {
    Name = "Docker-01"
  }
}

# Create Security Group for EC2
resource "aws_security_group" "default" {
  name = "Docker-sg"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}
output "instance_ips" {
  value = ["${aws_instance.default.*.public_ip}"]
}