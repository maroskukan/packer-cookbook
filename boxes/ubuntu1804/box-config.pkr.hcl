locals {
  version = formatdate("YYYY.MM.DD", timestamp())
}

variable "name" {
  type    = string
  default = "ubuntu1804"
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
  default = ["iso/ubuntu-18.04.6-server-amd64.iso", "https://cdimage.ubuntu.com/ubuntu/releases/18.04.6/release/ubuntu-18.04.6-server-amd64.iso"]
}

variable "iso_checksum" {
  type = string
  default = "f5cbb8104348f0097a8e513b10173a07dbc6684595e331cb06f93f385d0aecf6"
}

source "hyperv-iso" "vm" {
  boot_command          = [
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
                            "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
                            "ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 ",
                            "netcfg/get_domain='' ", "netcfg/get_hostname=${var.name} ",
                            "--- <enter>"
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
  enable_dynamic_memory = true
  enable_secure_boot    = false
  switch_name           = "Default switch"
  generation            = "1"
  output_directory      = "builds/${var.name}-hyperv"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

source "vmware-iso" "vm" {
  boot_command          = [
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
                            "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
                            "ipv6.disable_ipv6=1 net.ifnames=0 biosdevname=0 ",
                            "netcfg/get_domain='' ", "netcfg/get_hostname=${var.name} ",
                            "--- <enter>"
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
  vmx_data_post         = {
                          "virtualHW.version": "12",
                          "cleanShutdown": "true",
                          "softPowerOff": "true",
                          "ethernet0.virtualDev": "e1000",
                          "ethernet0.startConnected": "true",
                          "ethernet0.wakeonpcktrcv": "false"
                          }
  guest_os_type         = "ubuntu-64"
  vmx_remove_ethernet_interfaces = true
  version               = 12
  tools_upload_flavor   = "linux"
  output_directory      = "builds/${var.name}-hyperv"
  shutdown_command      = "echo 'vagrant' | sudo -S shutdown -P now"
}

build {
  sources = ["source.hyperv-iso.vm", "source.vmware-iso.vm"]

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

    // post-processor "vagrant-cloud" {
    //   box_tag = "maroskukan/${var.name}"
    //   version = "${local.version}"
    // }
  }
}
