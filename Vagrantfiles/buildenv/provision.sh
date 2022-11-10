#!/bin/sh


PACKER_VERSION="1.8.4-1"
VBOX_VERSION="7.0"
VBOX_EXT_VERSION="7.0.2"

# Get keys and add repository
wget -qO- https://apt.releases.hashicorp.com/gpg | gpg --dearmor --yes --output /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
     > /etc/apt/sources.list.d/hashicorp.list


wget -qO - https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --dearmor --yes --output /usr/share/keyrings/virtualbox.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/virtualbox.gpg] https://download.virtualbox.org/virtualbox/debian $(lsb_release -c -s) contrib" \
     > /etc/apt/sources.list.d/virtualbox.list

# Install packages
apt-get update
apt-get install -y virtualbox-"$VBOX_VERSION" \
                   packer="$PACKER_VERSION" \
                   bash-completion

# Retrieve and install VirtualBox Extensions
wget -q https://download.virtualbox.org/virtualbox/"$VBOX_EXT_VERSION"/Oracle_VM_VirtualBox_Extension_Pack-"$VBOX_EXT_VERSION".vbox-extpack \
     -O /tmp/Oracle_VM_VirtualBox_Extension_Pack-"$VBOX_EXT_VERSION".vbox-extpack

VBOX_EXT_SHA256="$(tar -xOzf /tmp/Oracle_VM_VirtualBox_Extension_Pack-7.0.2.vbox-extpack ./ExtPack-license.txt | sha256sum | head -c 64)"

vboxmanage extpack install --accept-license="$VBOX_EXT_SHA256" \
     /tmp/Oracle_VM_VirtualBox_Extension_Pack-"$VBOX_EXT_VERSION".vbox-extpack

# Configure Vbox networking - this will create default hostonly network vboxnet0 - 192.168.56.0/24
vboxmanage hostonlyif create
ip address add 192.168.56.1/24 dev vboxnet0