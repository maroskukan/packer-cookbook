#!/bin/bash -eu

NAME_SH=vagrant.sh

echo "==> ${NAME_SH}: Vagrant stage start.."

# Public key setup
echo "==> ${NAME_SH}: Downloading and installing public key.."
mkdir -pm 700 $HOME_DIR/.ssh
PUBKEY_URL="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub"
wget --no-check-certificate -O $HOME_DIR/.ssh/authorized_keys $PUBKEY_URL
chmod 0600 $HOME_DIR/.ssh/authorized_keys
chown -R vagrant:vagrant "${HOME_DIR}/.ssh"

# Passwordless sudo setup
echo "==> ${NAME_SH}: Updating sudo configuration.."
cat <<-EOF > /etc/sudoers.d/99_vagrant
Defaults:vagrant !fqdn
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/99_vagrant

echo "==> ${NAME_SH}: Vagrant stage end.."