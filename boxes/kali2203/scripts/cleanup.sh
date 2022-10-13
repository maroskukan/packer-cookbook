#!/bin/sh -eux


# Kernel cleanup - remove all except the current one
dpkg --list \
    | awk '{ print $2 }' \
    | grep 'linux-image-.*-kali' \
    | grep -v `uname -r` \
    | xargs apt-get -y purge;


# Software cleanup
apt-get -y purge popularity-contest installation-report command-not-found friendly-recovery laptop-detect;

# Exlude the files we don't need w/o uninstalling linux-firmware
cat <<EOF | cat >> /etc/dpkg/dpkg.cfg.d/excludes
path-exclude=/lib/firmware/*
path-exclude=/usr/share/doc/linux-firmware/*
EOF

# Delete the massive firmware packages
rm -rf /lib/firmware/*
rm -rf /usr/share/doc/linux-firmware/*

apt-get -y autoremove
apt-get -y clean

# Remove docs
rm -rf /usr/share/doc/*

# Remove caches
find /var/cache -type f -exec rm -rf {} \;

# truncate any logs that have built up during the install
find /var/log -type f -exec truncate --size=0 {} \;

# Blank netplan machine-id (DUID) so machines get unique ID generated on boot.
truncate -s 0 /etc/machine-id

# remove the contents of /tmp and /var/tmp
rm -rf /tmp/* /var/tmp/*

# clear the history so our install isn't there
export HISTSIZE=0
rm -f /root/.wget-hsts