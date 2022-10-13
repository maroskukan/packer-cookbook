locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "kali2203"
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
  type = list(string)
  default = ["iso/kali-linux-2022.3-installer-amd64.iso", "https://cdimage.kali.org/kali-2022.3/kali-linux-2022.3-installer-amd64.iso"]
}

variable "iso_checksum" {
  type = string
  default = "ae977f455924f0268fac437d66e643827089b6f8dc5d76324d6296eb11d997fd"
}

source "hyperv-iso" "vm" {
  boot_command          = ["<esc><wait>", "c", "<wait>", "linux /install.amd/vmlinuz ", "net.ifnames=0 ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ", "simple-cdd/profiles=kali,offline ", "desktop=xfce auto=true ", "priority=critical vga=768 ", "--- quiet<enter>", "initrd /install.amd/initrd.gz<enter>", "boot<enter>"]
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
  ssh_timeout           = "1800s"
  enable_dynamic_memory = true
  enable_secure_boot    = false
  switch_name           = "Default switch"
  generation            = "2"
  output_directory      = "builds/${var.name}-hyperv"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "virtualbox-iso" "vm" {
  boot_command          = ["<esc><wait>", "c", "<wait>", "linux /install.amd/vmlinuz ", "net.ifnames=0 ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ", "simple-cdd/profiles=kali,offline ", "desktop=xfce auto=true ", "priority=critical vga=768 ", "--- quiet<enter>", "initrd /install.amd/initrd.gz<enter>", "boot<enter>"]
  boot_wait        = "5s"
  communicator     = "ssh"
  vm_name          = "packer-${var.name}"
  cpus             = "${var.cpus}"
  memory           = "${var.memory}"
  disk_size        = "${var.disk_size}"
  iso_urls         = "${var.iso_urls}"
  iso_checksum     = "${var.iso_checksum}"
  headless         = false
  http_directory   = "http"
  ssh_username     = "vagrant"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "1800s"
  guest_os_type    = "Debian_64"
  output_directory = "builds/${var.name}-virtualbox"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["source.hyperv-iso.vm", "source.virtualbox-iso.vm"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts           = ["scripts/sshd.sh", "scripts/vagrant.sh", "scripts/cleanup.sh", "scripts/minimize.sh", "scripts/swapoff.sh"]
    expect_disconnect = true
  }
  post-processors {
    post-processor "vagrant" {
      output = "builds/${var.name}-{{.Provider}}.box"
    }

    post-processor "vagrant-cloud" {
      box_tag = "maroskukan/kali2203"
      version = "${local.version}"
    }
  }
}
