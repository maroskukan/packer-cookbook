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

data "aws_ami" "packer_image" {
  most_recent = true

  filter {
    name = "tag:Created-by"
    values = ["Packer"]
  }

  filter {
    name = "tag:Name"
    values = [var.appname]
  }

  owners = ["self"]
}

resource "aws_instance" "test_ami" {
  ami           = data.aws_ami.packer_image.image_id
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