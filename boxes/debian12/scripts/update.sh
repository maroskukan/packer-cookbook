#!/bin/bash -eux


printf "Update stage.\n"

export DEBIAN_FRONTEND=noninteractive

# Update list of packages and upgrade all packages
apt-get update;
apt-get -y upgrade;

# Switch to testing release
# https://wiki.debian.org/DebianTesting
if [ "$RELEASE" = "testing" ]; then
  printf "Update to testing release.\n"
  sed -i.bak 's/bookworm/testing/g' /etc/apt/sources.list
  apt-get update
  apt-get -y dist-upgrade
fi

# Boot to new kernel if applicable
if [[ `dpkg -l | grep -c 'linux-image-[0-9]'` != 1 ]]; then
  printf "Multiple kernels available. Will reboot.\n"
  ( shutdown --reboot --no-wall +1 ) &
  exit 0
else
 printf "One kernel found. Reboot skipped.\n"
 exit 0
fi