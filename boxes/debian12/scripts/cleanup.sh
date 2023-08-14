#!/bin/bash -eux

printf "Cleanup stage.\n"

# Remove any old kernels and modules
if [[ `dpkg -l | grep -c 'linux-image-[0-9]'` != 1 ]]; then
  apt-get purge $(dpkg -l | grep 'linux-image-[0-9]' | awk '{print $2}' | grep -v $(uname -r))
fi

# Clean up apt
apt-get clean

# Remove artifacts from installation
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /root/debian-installer-logs/*

# Clear the random seed.
rm -f /var/lib/systemd/random-seed

# Truncate the log files.
printf "Truncate the log files.\n"
find /var/log -type f -exec truncate --size=0 {} \;

# Wipe the temp directory.
printf "Purge the setup files and temporary data.\n"
rm -rf /var/tmp/* /tmp/* /var/cache/apt/* /tmp/debian-installer-script*

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