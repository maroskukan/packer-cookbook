packer {
  required_version = ">= 1.7.0"
  required_plugins {
    hyperv = {
      version = ">= 1.1.1"
      source  = "github.com/hashicorp/hyperv"
    }
    vmware = {
      version = ">= 1.0.8"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "ubuntu2210"
}

variable "cpus" {
  type    = string
  default = "2"
}

variable "memory" {
  type    = string
  default = "2048"
}

variable "disk_size" {
  type    = string
  default = "81920"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "iso_urls" {
  type    = list(string)
  default = ["iso/ubuntu-22.10-live-server-amd64.iso", "https://releases.ubuntu.com/22.10/ubuntu-22.10-live-server-amd64.iso"]
}

variable "iso_checksum" {
  type    = string
  default = "874452797430a94ca240c95d8503035aa145bd03ef7d84f9b23b78f3c5099aed"
}

source "hyperv-iso" "efi" {
  boot_command          = [
                           "c",
                           "linux /casper/vmlinuz autoinstall quiet net.ifnames=0 biosdevname=0 ",
                           "ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' --- <enter><wait>",
                           "initrd /casper/initrd<enter><wait>",
                           "boot<enter>"
                          ]
  boot_wait             = "5s"
  communicator          = "ssh"
  vm_name               = "packer-${var.name}"
  cpus                  = "${var.cpus}"
  memory                = "${var.memory}"
  disk_size             = "${var.disk_size}"
  iso_urls              = "${var.iso_urls}"
  iso_checksum          = "${var.iso_checksum}"
  headless              = false
  http_directory        = "http"
  ssh_username          = "vagrant"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "3600s"
  enable_dynamic_memory = false
  enable_secure_boot    = true
  guest_additions_mode  = "disable"
  switch_name           = "Default switch"
  generation            = "2"
  secure_boot_template  = "MicrosoftUEFICertificateAuthority"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "vmware-iso" "efi" {
  boot_command          = [
                           "c",
                           "linux /casper/vmlinuz autoinstall net.ifnames=0 biosdevname=0 ",
                           "ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' --- <enter><wait>",
                           "initrd /casper/initrd<enter><wait>",
                           "boot<enter>"
                          ]
  boot_wait             = "5s"
  communicator          = "ssh"
  vm_name               = "packer-${var.name}"
  cpus                  = "${var.cpus}"
  memory                = "${var.memory}"
  disk_size             = "${var.disk_size}"
  iso_urls              = "${var.iso_urls}"
  iso_checksum          = "${var.iso_checksum}"
  headless              = false
  http_directory        = "http"
  ssh_username          = "vagrant"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "3600s"
  vnc_disable_password  = true
  vnc_bind_address      = "127.0.0.1"
  vmx_data              = {
                            "firmware" = "efi"
                          }
  vmx_data_post         = {
                          "virtualHW.version": "18",
                          "cleanShutdown": "true",
                          "softPowerOff": "true",
                          "ethernet0.virtualDev": "e1000",
                          "ethernet0.startConnected": "true",
                          "ethernet0.wakeonpcktrcv": "false"
                          }
  guest_os_type         = "ubuntu-64"
  vmx_remove_ethernet_interfaces = true
  version               = 18
  tools_upload_flavor   = "linux"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "virtualbox-iso" "efi" {
  boot_command          = [
                           "c",
                           "linux /casper/vmlinuz autoinstall net.ifnames=0 biosdevname=0 ",
                           "ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' --- <enter><wait>",
                           "initrd /casper/initrd<enter><wait>",
                           "boot<enter>"
                          ]
  boot_wait             = "5s"
  communicator          = "ssh"
  vm_name               = "packer-${var.name}"
  cpus                  = "${var.cpus}"
  memory                = "${var.memory}"
  disk_size             = "${var.disk_size}"
  iso_urls              = "${var.iso_urls}"
  iso_checksum          = "${var.iso_checksum}"
  headless              = false
  http_directory        = "http"
  ssh_username          = "vagrant"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "3600s"
  firmware              = "efi"
  vboxmanage            = [
                            ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],
                          ]
  guest_os_type         = "Ubuntu_64"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["source.hyperv-iso.efi", "sources.vmware-iso.efi", "sources.virtualbox-iso.efi"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts           = ["scripts/setup.sh", "scripts/vagrant.sh", "scripts/cleanup.sh"]
    expect_disconnect = true
  }
  post-processors {
    post-processor "vagrant" {
      output = "builds/${var.name}-{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "maroskukan/${var.name}"
      version = "${local.version}"
    }
  }
}
