#!/bin/bash

printf "Cleanup stage.\n"

# Remove any old kernels and modules
if [[ `rpm -q kernel | wc -l` != 1 ]]; then
  dnf --setopt=protected_packages= -y remove $(dnf repoquery --installonly --latest-limit=-1 -q)
fi

# Clean up dnf
dnf -y clean all

# Remove artifacts from installation
rm -rf /root/anaconda-ks.cfg /root/original-ks.cfg /var/log/anaconda/*

# Clear the random seed.
rm -f /var/lib/systemd/random-seed

# Truncate the log files.
printf "Truncate the log files.\n"
find /var/log -type f -exec truncate --size=0 {} \;

# Wipe the temp directory.
printf "Purge the setup files and temporary data.\n"
rm -rf /var/tmp/* /tmp/* /var/cache/dnf/* /tmp/ks-script*

# Whiteout root
count=$(df --sync -kP / | tail -n1  | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/tmp/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /tmp/whitespace

# Whiteout /boot
count=$(df --sync -kP /boot | tail -n1 | awk -F ' ' '{print $4}')
count=$(($count-1))
dd if=/dev/zero of=/boot/whitespace bs=1M count=$count || echo "dd exit code $? is suppressed";
rm /boot/whitespace

# Clear the command history.
export HISTSIZE=0

sync

exit 0