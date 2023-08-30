#!/bin/bash -eu

NAME_SH=update.sh

echo "==> ${NAME_SH}: Update stage start.."

export DEBIAN_FRONTEND=noninteractive

echo "==> ${NAME_SH}: Updating list of packages and upgrading all packages.."
apt-get update
apt-get -y upgrade

# Switch to testing release
# https://wiki.debian.org/DebianTesting
if [ "${DEBIAN_RELEASE}" = "testing" ]; then
  echo "==> ${NAME_SH}: Switching to Debian Testing release.."
  sed -i.bak 's/bookworm/testing/g' /etc/apt/sources.list
  apt-get update
  apt-get -y dist-upgrade
else
  echo "==> ${NAME_SH}: Using Debian Stable release.."
fi

# Boot to new kernel if applicable
if [[ `dpkg -l | grep -c 'linux-image-[0-9]'` != 1 ]]; then
  echo "==> ${NAME_SH}: Multiple kernels available.."
  echo "==> ${NAME_SH}: Rebooting to ensure latest is used.."
  echo "==> ${NAME_SH}: Update stage end.."
  ( shutdown --reboot --no-wall +1 ) &
  exit 0
else
 echo "==> ${NAME_SH}: Single kernel found, no reboot required.."
 echo "==> ${NAME_SH}: Update stage end.."
 exit 0
fi