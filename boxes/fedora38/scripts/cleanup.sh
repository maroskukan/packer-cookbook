#!/bin/bash

printf "Cleanup stage.\n"

# Remove any old kernels and modules
if [[ `rpm -q kernel | wc -l` != 1 ]]; then
  echo "==> ${NAME_SH}: Removing any old kernels and modules.."
  dnf --setopt=protected_packages= -y remove $(dnf repoquery --installonly --latest-limit=-1 -q)
fi

# Clean up dnf
echo "==> ${NAME_SH}: Cleaning up yum cache and history.."
dnf -y clean all
rm -rf /var/lib/dnf/history.sqlite*
dnf history

# Remove artifacts from installation
echo "==> ${NAME_SH}: Cleaning installation artifacts.."
rm -rf /root/anaconda-ks.cfg /root/original-ks.cfg /var/log/anaconda/*

# Clear the random seed.
echo "==> ${NAME_SH}: Clearing random seed.."
rm -f /var/lib/systemd/random-seed

# Truncate the log files.
echo "==> ${NAME_SH}: Truncating the log files.."
find /var/log -type f -exec truncate --size=0 {} \;

# Wipe the temp directory.
echo "==> ${NAME_SH}: Cleaning the setup files and temporary files.."
rm -rf /var/tmp/* /tmp/* /var/cache/dnf/* /tmp/ks-script*

# Whiteout root.
echo "==> ${NAME_SH}: Whiting out the root partition.."
dd if=/dev/zero of=/tmp/whitespace bs=16M || true
rm /tmp/whitespace

# Whiteout /boot.
echo "==> ${NAME_SH}: Whiting out the boot partition.."
dd if=/dev/zero of=/boot/whitespace bs=16M || true
rm /boot/whitespace


# Clear the command history.
echo "==> ${NAME_SH}: Cleaning up the history.."
export HISTSIZE=0

sync

echo "==> ${NAME_SH}: Cleanup stage end.."