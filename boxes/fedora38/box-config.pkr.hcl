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
    virtualbox = {
      version = ">= 1.0.5"
      source  = "github.com/hashicorp/virtualbox"
    }
  }
}

locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "fedora38"
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
  default = ["iso/Fedora-Server-netinst-x86_64-38-1.6.iso", "https://download.fedoraproject.org/pub/fedora/linux/releases/38/Server/x86_64/iso/Fedora-Server-netinst-x86_64-38-1.6.iso"]
}

variable "iso_checksum" {
  type    = string
  default = "192af621553aa32154697029e34cbe30152a9e23d72d55f31918b166979bbcf5"
}

source "hyperv-iso" "efi" {
  boot_command          = [
                           "c",
                           "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-38 ",
                           "ipv6.disable=1 net.ifnames=0 biosdevname=0 ",
                           "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg --- <enter><wait>",
                           "initrdefi /images/pxeboot/initrd.img<enter><wait>",
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
  configuration_version = "10.0"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "vmware-iso" "efi" {
  boot_command          = [
                           "c",
                           "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-38 ",
                           "ipv6.disable=1 net.ifnames=0 biosdevname=0 ",
                           "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg --- <enter><wait>",
                           "initrdefi /images/pxeboot/initrd.img<enter><wait>",
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
                          "softPowerOff": "false",
                          "ethernet0.virtualDev": "e1000",
                          "ethernet0.startConnected": "true",
                          "ethernet0.wakeonpcktrcv": "false"
                          }
  guest_os_type         = "fedora-64"
  vmx_remove_ethernet_interfaces = true
  version               = 18
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "virtualbox-iso" "efi" {
  boot_command          = [
                           "c",
                           "linuxefi /images/pxeboot/vmlinuz inst.stage2=hd:LABEL=Fedora-S-dvd-x86_64-38 ",
                           "ipv6.disable=1 net.ifnames=0 biosdevname=0 ",
                           "inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg --- <enter><wait>",
                           "initrdefi /images/pxeboot/initrd.img<enter><wait>",
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
                            ["modifyvm", "{{.Name}}", "--vram", "64"]
                          ]
  guest_os_type         = "Fedora_64"
  guest_additions_mode  = "disable"
  hard_drive_interface  = "sata"
  output_directory      = "builds/${var.name}-${source.name}-${source.type}"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["hyperv-iso.efi", "vmware-iso.efi", "virtualbox-iso.efi"]

  provisioner "shell" {
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh '{{ .Path }}'"
    scripts           = ["scripts/update.sh"]
    expect_disconnect = true
  }
  provisioner "shell" {
    pause_before      = "120s"
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh '{{ .Path }}'"
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