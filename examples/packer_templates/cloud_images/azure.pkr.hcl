source "azure-arm" "ubuntu_16" {
  subscription_id                   = "e1f6a3f2-9d19-4e32-bcc3-1ef1517e0fa5"
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-ubuntu-azure-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "UbuntuServer"
  image_sku       = "16.04-LTS"

  azure_tags = {
    Created-by = "Packer"
    OS_Version = "Ubuntu 16.04"
    Release    = "Latest"
  }

  location = "East US"
  vm_size  = "Standard_A2"
}

source "azure-arm" "ubuntu_20" {
  subscription_id                   = "e1f6a3f2-9d19-4e32-bcc3-1ef1517e0fa5"
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-ubuntu-azure-{{timestamp}}"

  os_type         = "Linux"
  image_publisher = "Canonical"
  image_offer     = "0001-com-ubuntu-server-focal"
  image_sku       = "20_04-lts"

  azure_tags = {
    Created-by = "Packer"
    OS_Version = "Ubuntu 20.04"
    Release    = "Latest"
  }

  location = "East US"
  vm_size  = "Standard_A2"
}

source "azure-arm" "windows_2012r2" {
  subscription_id                   = "e1f6a3f2-9d19-4e32-bcc3-1ef1517e0fa5"
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-w2k12r2-azure-{{timestamp}}"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2012-R2-Datacenter"

  communicator     = "winrm"
  winrm_use_ssl    = true
  winrm_insecure   = true
  winrm_timeout    = "5m"
  winrm_username   = "packer"
  custom_data_file = "./scripts/SetUpWinRM.ps1"

  azure_tags = {
    Created-by = "Packer"
    OS_Version = "Windows 2012R2"
    Release    = "Latest"
  }

  location = "East US"
  vm_size  = "Standard_A2"
}

source "azure-arm" "windows_2019" {
  subscription_id                   = "e1f6a3f2-9d19-4e32-bcc3-1ef1517e0fa5"
  managed_image_resource_group_name = "packer_images"
  managed_image_name                = "packer-w2k19-azure-{{timestamp}}"

  os_type         = "Windows"
  image_publisher = "MicrosoftWindowsServer"
  image_offer     = "WindowsServer"
  image_sku       = "2019-Datacenter"

  communicator     = "winrm"
  winrm_use_ssl    = true
  winrm_insecure   = true
  winrm_timeout    = "5m"
  winrm_username   = "packer"
  custom_data_file = "./scripts/SetUpWinRM.ps1"

  azure_tags = {
    Created-by = "Packer"
    OS_Version = "Windows 2019"
    Release    = "Latest"
  }

  location = "East US"
  vm_size  = "Standard_A2"
}