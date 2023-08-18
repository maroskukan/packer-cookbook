#!/usr/bin/env bash

set -e
if [ -n "$BUILD_DEBUG" ] && set -x

NAME_SH=vagrant.sh

echo "==> ${NAME_SH}: Vagrant stage start.."


# Public key setup
echo "==> ${NAME_SH}: Downloading and installing public key.."
mkdir -pm 700 $HOME_DIR/.ssh;
pubkey_url="https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub";
curl --insecure --location "$pubkey_url" > $HOME_DIR/.ssh/authorized_keys;
chmod 0600 $HOME_DIR/.ssh/authorized_keys
chown -R vagrant:vagrant $HOME_DIR/.ssh

# Passwordless sudo setup
echo "==> ${NAME_SH}: Updating sudo configuration.."
cat <<-EOF > /etc/sudoers.d/99_vagrant
Defaults:vagrant !fqdn
Defaults:vagrant !requiretty
vagrant ALL=(ALL) NOPASSWD: ALL
EOF
chmod 0440 /etc/sudoers.d/99_vagrant

echo "==> ${NAME_SH}: Vagrant stage end.."