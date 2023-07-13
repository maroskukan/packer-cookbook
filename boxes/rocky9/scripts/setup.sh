#!/bin/bash -eux

# Upgrade all installed packages
dnf -y upgrade

# Setup key-based authentication
pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
mkdir -m 700 -p $HOME_DIR/.ssh;
if command -v curl >/dev/null 2>&1; then
    curl --insecure --location "$pubkey_url" > $HOME_DIR/.ssh/authorized_keys;
else
    echo "Cannot download vagrant public key";
    exit 1;
fi
chown -R vagrant:vagrant $HOME_DIR/.ssh;