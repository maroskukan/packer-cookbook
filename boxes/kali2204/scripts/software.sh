#!/bin/sh -eux


# Update cache and ugprade packages
echo "Update cache and ugprade packages"
export DEBIAN_FRONTEND=noninteractive
export DEBIAN_PRIORITY=critical
apt-get -qy clean
apt-get -qy update
apt-get -qy -o "Dpkg::Options::=--force-confdef" -o "Dpkg::Options::=--force-confold" upgrade


# Install metapackages - DE/WM is not included by default
# https://www.kali.org/docs/general-use/metapackages/
echo "Install metapackage kali-linux-default"
apt-get install -y kali-linux-default


# Install hypervisor specific tools
if [ "$PACKER_BUILDER_TYPE" = "hyperv-iso" ]; then
    echo "Install hyperv guest support tools"
    apt-get install -y hyperv-daemons
elif [ "$PACKER_BUILDER_TYPE" = "virtualbox-iso" ]; then
    echo "Install virtualbox guest support tools"
    apt-get install -y virtualbox-guest-x11
else
    echo "Installation of hypervisor guest support tools skipped."
fi