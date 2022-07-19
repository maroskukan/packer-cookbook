variable "version" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = "ubuntu1804"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "memory" {
  type    = string
  default = "1024"
}

variable "disk_size" {
  type    = string
  default = "65536"
}

variable "http_proxy" {
  type    = string
  default = "${env("http_proxy")}"
}

variable "https_proxy" {
  type    = string
  default = "${env("https_proxy")}"
}

variable "name" {
  type    = string
  default = "ubuntu1804"
}

variable "no_proxy" {
  type    = string
  default = "${env("no_proxy")}"
}

variable "iso_urls" {
  type = list
  default = ["iso/ubuntu-18.04.5-server-amd64.iso", "https://old-releases.ubuntu.com/releases/18.04.5/ubuntu-18.04.5-server-amd64.iso"]
}

variable "iso_checksum" {
  type = string
  default = "8c5fc24894394035402f66f3824beb7234b757dd2b5531379cb310cedfdf0996"
}

source "hyperv-iso" "vm" {
  boot_command          = ["<esc><wait10><esc><esc><enter><wait>", "set gfxpayload=1024x768<enter>", "linux /install/vmlinuz ", "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ", "debian-installer=en_US.UTF-8 auto locale=en_US.UTF-8 kbd-chooser/method=us ", "hostname=${var.name} ", "fb=false debconf/frontend=noninteractive ", "keyboard-configuration/modelcode=SKIP keyboard-configuration/layout=USA ", "keyboard-configuration/variant=USA console-setup/ask_detect=false <enter>", "initrd /install/initrd.gz<enter>", "boot<enter>"]
  boot_wait             = "5s"
  communicator          = "ssh"
  cpus                  = "${var.cpus}"
  disk_size             = "${var.disk_size}"
  enable_dynamic_memory = true
  enable_secure_boot    = false
  generation            = "2"
  headless              = true
  http_directory        = "http"
  iso_urls              = "${var.iso_urls}"
  iso_checksum          = "${var.iso_checksum}"
  memory                = "${var.memory}"
  output_directory      = "builds/${var.name}-hyperv"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password          = "vagrant"
  ssh_port              = 22
  ssh_timeout           = "1800s"
  ssh_username          = "vagrant"
  switch_name           = "Default switch"
  vm_name               = "packer-${var.name}"
}

source "virtualbox-iso" "vm" {
  boot_command     = ["<esc><wait>", "<esc><wait>", "<enter><wait>", "/install/vmlinuz<wait>", " auto<wait>", " console-setup/ask_detect=false<wait>", " console-setup/layoutcode=us<wait>", " console-setup/modelcode=pc105<wait>", " debconf/frontend=noninteractive<wait>", " debian-installer=en_US<wait>", " fb=false<wait>", " initrd=/install/initrd.gz<wait>", " kbd-chooser/method=us<wait>", " keyboard-configuration/layout=USA<wait>", " keyboard-configuration/variant=USA<wait>", " locale=en_US<wait>", " netcfg/get_domain=vm<wait>", " netcfg/get_hostname=vagrant<wait>", " grub-installer/bootdev=/dev/sda<wait>", " noapic<wait>", " preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg<wait>", " -- <wait>", "<enter><wait>"]
  boot_wait        = "10s"
  communicator     = "ssh"
  cpus             = "${var.cpus}"
  disk_size        = "${var.disk_size}"
  guest_os_type    = "Ubuntu_64"
  headless         = false
  http_directory   = "http"
  iso_urls         = "${var.iso_urls}"
  iso_checksum     = "${var.iso_checksum}"
  memory           = "${var.memory}"
  output_directory = "builds/${var.name}-virtualbox"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
  ssh_password     = "vagrant"
  ssh_port         = 22
  ssh_timeout      = "1800s"
  ssh_username     = "vagrant"
  vm_name          = "packer-${var.name}"
}

build {
  sources = ["source.hyperv-iso.vm", "source.virtualbox-iso.vm"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts           = ["scripts/update.sh", "scripts/motd.sh", "scripts/sshd.sh", "scripts/networking.sh", "scripts/sudoers.sh", "scripts/vagrant.sh", "scripts/hyperv.sh", "scripts/cleanup.sh", "scripts/minimize.sh", "scripts/swapoff.sh"]
    expect_disconnect = true
  }

  post-processor "vagrant" {
    output = "builds/${var.name}-${source.type}.box"
  }
}
