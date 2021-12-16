variable "aws_region" {
  type    = string
  default = "${env("AWS_REGION")}"
}

variable "vault_zip" {
  type    = string
  default = "/tmp/vault_1.9.1_linux_amd64.zip"
}

variable "vpc_id" {
  type    = string
  default = "vpc-04c0d6872786b4432"
}

variable "subnet_id" {
  type    = string
  default = "subnet-06ba1b9523c9f3760"
}

data "amazon-ami" "amazon-linux-2" {
  filters = {
    name                = "amzn2-ami-hvm-2.*-x86_64-gp2"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["amazon"]
  region      = var.aws_region
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "amazon-ebs" "amazon-ebs-amazonlinux-2" {
  ami_description             = "Vault - Amazon Linux 2"
  ami_name                    = "vault-amazonlinux2-${local.timestamp}"
  ami_regions                 = ["us-west-2"]
  ami_virtualization_type     = "hvm"
  associate_public_ip_address = true
  force_delete_snapshot       = true
  force_deregister            = true
  instance_type               = "t2.micro"
  region                      = var.aws_region
  source_ami                  = data.amazon-ami.amazon-linux-2.id
  spot_price                  = "0"
  ssh_pty                     = true
  ssh_timeout                 = "5m"
  ssh_username                = "ec2-user"
  tags = {
    Name = "HashiCorp Vault"
    OS   = "Amazon Linux 2"
  }
  subnet_id = var.subnet_id
  vpc_id    = var.vpc_id
}

build {
  sources = ["source.amazon-ebs.amazon-ebs-amazonlinux-2"]

  provisioner "file" {
    destination = "/tmp/vault.zip"
    source      = var.vault_zip
  }
}