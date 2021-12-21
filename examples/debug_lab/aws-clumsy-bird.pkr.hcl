source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "Clumsy Bird"
    "Environment" = "Production"
    "OS_Version"  = "Ubuntu 20.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

build {
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Updating Packeges Lists",
      "sudo apt-get update",
    ]
  }

  provisioner "shell" {
    inline = [
      "echo Testing"
    ]
  }

  provisioner "breakpoint" {
    disable = false
    note    = "innspect before installing nginx"
  }

  provisioner "shell" {
    inline = [
      "sudo apt-get install -y nginx"
    ]
  }

  provisioner "breakpoint" {
    disable = false
    note    = "vaidate after installing nginx"
  }

  provisioner "file" {
    source      = "assets"
    destination = "/tmp"
  }

  provisioner "breakpoint" {
    disable = false
    note    = "validate files are uploaded"
  }

  post-processor "manifest" {}

}