locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "ubuntu2204"
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
  default = ["iso/ubuntu-22.04.1-live-server-amd64.iso", "https://releases.ubuntu.com/22.04/ubuntu-22.04.1-live-server-amd64.iso"]
}

variable "iso_checksum" {
  type    = string
  default = "10f19c5b2b8d6db711582e0e27f5116296c34fe4b313ba45f9b201a5007056cb"
}

source "hyperv-iso" "vm" {
  boot_command = [
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
  headless              = true
  http_directory        = "http"
  ssh_username          = "vagrant"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "3600s"
  enable_dynamic_memory = true
  enable_secure_boot    = false
  guest_additions_mode  = "disable"
  switch_name           = "Default switch"
  generation            = "2"
  output_directory      = "builds/${var.name}-hyperv"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "virtualbox-iso" "vm" {
  boot_command = [
    "c",
    "linux /casper/vmlinuz --- autoinstall ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/' ",
    "<enter><wait>",
    "initrd /casper/initrd<enter><wait>",
    "boot<enter>"
  ]
  boot_wait        = "5s"
  communicator     = "ssh"
  vm_name          = "packer-${var.name}"
  cpus             = "${var.cpus}"
  memory           = "${var.memory}"
  disk_size        = "${var.disk_size}"
  iso_urls         = "${var.iso_urls}"
  iso_checksum     = "${var.iso_checksum}"
  headless         = true
  http_directory   = "http"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "3600s"
  guest_os_type    = "Ubuntu_64"
  output_directory = "builds/${var.name}-virtualbox"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["source.hyperv-iso.vm", "source.virtualbox-iso.vm"]

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
    // post-processor "vagrant-cloud" {
    //   box_tag = "maroskukan/${var.name}"
    //   version = "${local.version}"
    // }
  }
}
