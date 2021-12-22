variable "ami" {
  type = string
  description = "Application Image to Deploy"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "appname" {
  type    = string
  description = "Application Name"
}

provider "aws" {
  region = var.region
}

resource "aws_instance" "test_ami" {
  ami           = var.ami
  instance_type = "t2.micro"
  key_name      = "MyEC2Instance"

  tags = {
    "Name" = var.appname
  }
}

output "public_ip" {
  value = aws_instance.test_ami.public_ip
}

output "public_dns" {
  value = aws_instance.test_ami.public_dns
}

output "clumsy_bird" {
  value = "http://${aws_instance.test_ami.public_dns}:8001"
}