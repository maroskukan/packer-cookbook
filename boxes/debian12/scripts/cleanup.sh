#!/bin/bash -eu

NAME_SH=setup.sh

echo "==> ${NAME_SH}: Cleanup stage start.."

export DEBIAN_FRONTEND=noninteractive

# Remove any old kernels and modules
echo "==> ${NAME_SH}: Removing any old kernels and modules.."
if [[ `dpkg -l | grep -c 'linux-image-[0-9]'` != 1 ]]; then
  apt-get -y purge $(dpkg -l | grep 'linux-image-[0-9]' | awk '{print $2}' | grep -v $(uname -r))
fi

# Clean up apt
echo "==> ${NAME_SH}: Cleaning up apt cache.."
apt-get clean

# Remove artifacts from installation
echo "==> ${NAME_SH}: Cleaning installation artifacts.."
rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/* /root/debian-installer-logs/*

# Clear the random seed.
echo "==> ${NAME_SH}: Clearing random seed.."
rm -f /var/lib/systemd/random-seed

# Truncate the log files.
echo "==> ${NAME_SH}: Truncating the log files.."
find /var/log -type f -exec truncate --size=0 {} \;

# Wipe the temp directory.
echo "==> ${NAME_SH}: Cleaning the setup files and temporary files.."
rm -rf /var/tmp/* /tmp/* /var/cache/apt/* /tmp/debian-installer-script*

# Whiteout root.
echo "==> ${NAME_SH}: Whiting out the root partition.."
dd if=/dev/zero of=/tmp/whitespace bs=16M 2>/dev/null || true
rm /tmp/whitespace

# Whiteout /boot.
echo "==> ${NAME_SH}: Whiting out the boot partition.."
dd if=/dev/zero of=/boot/whitespace bs=16M 2>/dev/null || true
rm /boot/whitespace

# Clear the command history.
echo "==> ${NAME_SH}: Cleaning up the history.."
export HISTSIZE=0

# Flush in-memory data to disk
sync

echo "==> ${NAME_SH}: Cleanup stage end.."