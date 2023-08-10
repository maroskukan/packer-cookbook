#!/bin/bash -ux

# Enable exit/failure on error.
set -eux

printf "Vagrant stage.\n"

# Public key setup
mkdir -pm 700 $HOME_DIR/.ssh;
pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
curl --insecure --location "$pubkey_url" > $HOME_DIR/.ssh/authorized_keys;
chmod 0600 $HOME_DIR/.ssh/authorized_keys
chown -R vagrant:vagrant $HOME_DIR/.ssh

# Passwordless sudo setup
cat <<-EOF > /etc/sudoers.d/99_vagrant
Defaults:vagrant !fqdn
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/99_vagrant