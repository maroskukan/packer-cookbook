#!/bin/sh


PACKER_VERSION="1.8.4-1"
VBOX_VERSION="7.0"

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
                   packer="$PACKER_VERSION"