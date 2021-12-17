source "amazon-ebs" "ubuntu" {
  ami_name      = "packer-ubuntu-aws-{{timestamp}}"
  instance_type = "t2.micro"
  region        = "us-west-2"
  ami_regions   = ["us-west-2", "us-east-1", "eu-central-1"]
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-xenial-16.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"
  tags = {
    "Name"        = "MyUbuntuImage"
    "Environment" = "Production"
    "OS_Version"  = "Ubuntu 16.04"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

source "azure-arm" "ubuntu" {
  # client_id                         = "XXXX"
  # client_secret                     = "XXXX"
  # tenant_id                         = "XXXX"
  # subscription_id                   = "XXXX"
  use_azure_cli_auth                = true
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-ubuntu-azure-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"

  azure_tags = {
    Created-by = "Packer"
    OS_Version = "Ubuntu 20.04"
    Rekease    = "Latest"
  }

  location = "East US"
  vm_size  = "Standard_B1ls"
}

build {
  sources = [
    "source.amazon-ebs.ubuntu",
    "source.azure-arm.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update -y",
      "sudo apt-get install -y nginx"
    ]
  }

  provisioner "shell" {
    only   = ["source.amazon-ebs.ubuntu"]
    inline = ["sudo apt-get install awscli"]
  }

  provisioner "shell" {
    only   = ["source.azure-arm.ubuntu"]
    inline = ["sudo apt-get install azure-cli"]
  }

  post-processor "manifest" {}
}