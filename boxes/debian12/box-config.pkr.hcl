locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "debian12"
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
  default = ["iso/debian-12.0.0-amd64-netinst.iso", "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-12.0.0-amd64-netinst.iso"]
}

variable "iso_checksum" {
  type = string
  default = "b462643a7a1b51222cd4a569dad6051f897e815d10aa7e42b68adc8d340932d861744b5ea14794daa5cc0ccfa48c51d248eda63f150f8845e8055d0a5d7e58e6"
}


source "virtualbox-iso" "efi" {
  boot_command     = [
                      "<esc><wait>","<esc><wait>","<enter><wait>",
                      "/install/vmlinuz<wait> ",
                      "auto ",
                      "console-setup/ask_detect=false ",
                      "console-setup/layoutcode=us ",
                      "console-setup/modelcode=pc105 ",
                      "debconf/frontend=noninteractive ",
                      "debian-installer=en_US ",
                      "fb=false ",
                      "initrd=/install/initrd.gz ",
                      "kbd-chooser/method=us ",
                      "keyboard-configuration/layout=USA ",
                      "keyboard-configuration/variant=USA ",
                      "locale=en_US ",
                      "noapic ",
                      "preseed/url=http://192.168.56.1:{{ .HTTPPort }}/preseed.cfg ",
                      "ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 ",
                      "netcfg/get_domain='' ", "netcfg/get_hostname=${var.name} ",
                      "--- <enter>"
                     ]
  boot_wait        = "10s"
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
  ssh_timeout      = "3600s"
  guest_os_type    = "Ubuntu_64"
  hard_drive_interface = "sata"
  vboxmanage      = [
                      [
                        "modifyvm",
                        "{{.Name}}",
                        "--vram",
                        "64"
                      ]
                    ]
  output_directory = "builds/${var.name}-virtualbox"
  shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["virtualbox-iso.efi"]

  provisioner "shell" {
    environment_vars  = ["HOME_DIR=/home/vagrant", "http_proxy=${var.http_proxy}", "https_proxy=${var.https_proxy}", "no_proxy=${var.no_proxy}"]
    execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
    scripts           = ["scripts/update.sh", "scripts/sshd.sh", "scripts/networking.sh", "scripts/sudoers.sh", "scripts/vagrant.sh", "scripts/vmtools.sh", "scripts/cleanup.sh", "scripts/minimize.sh", "scripts/swapoff.sh"]
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
