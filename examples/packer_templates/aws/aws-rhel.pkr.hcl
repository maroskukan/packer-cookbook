source "amazon-ebs" "rhel" {
  ami_name      = "packer-rhel-aws-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "RHEL_HA-8.4.0_HVM-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["309956199498"]
  }
  ssh_username = "ec2-user"
}
build {
  sources = [
      "source.amazon-ebs.rhel"
      ]
}