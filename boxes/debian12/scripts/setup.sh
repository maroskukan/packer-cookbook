#!/bin/bash -eux


export DEBIAN_FRONTEND=noninteractive

# Workaround for vbox gray box
# https://forums.debian.net/viewtopic.php?t=155301
if [ "$PACKER_BUILDER_TYPE" = "virtualbox-iso" ]; then
    sed -i 's/bullseye/bookworm/g' /etc/apt/sources.list;
    apt-get -y update;
    apt-get -y upgrade --without-new-pkgs;
    apt-get -y full-upgrade
    systemctl reboot

fi

# Upgrade all installed packages
apt-get -y upgrade;