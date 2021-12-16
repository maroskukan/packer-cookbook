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
  name = "ubuntu"
  sources = [
    "source.azure-arm.ubuntu"
  ]

  provisioner "shell" {
    inline = [
      "echo Installing Updates",
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]
  }

  provisioner "shell" {
    inline = ["curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"]
  }
}