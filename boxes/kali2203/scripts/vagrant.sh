#!/bin/bash -eux


# Add vagrant insurecure public key
pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub"
mkdir -p /home/vagrant/.ssh
if command -v wget >/dev/null 2>&1; then
    wget --no-check-certificate "$pubkey_url" -O /home/vagrant/.ssh/authorized_keys
else
    echo "Cannot download vagrant public key"
    exit 1
fi
chmod 0700 /home/vagrant/.ssh/
chmod 0600 /home/vagrant/.ssh/authorized_keys
chown -R vagrant:vagrant /home/vagrant/.ssh

# Set up password-less sudo for the vagrant user
echo 'vagrant ALL=(ALL) NOPASSWD:ALL' >/etc/sudoers.d/vagrant
chmod 0440 /etc/sudoers.d/vagrant

