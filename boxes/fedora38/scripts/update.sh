#!/usr/bin/env bash

set -e
if [ -n "$BUILD_DEBUG" ] && set -x

NAME_SH=update.sh

echo "==> ${NAME_SH}: Update stage start.."

echo "==> ${NAME_SH}: Updating list of packages and upgrading all packages.."
dnf update
dnf upgrade -y

# Boot to new kernel if applicable
if [[ `rpm -q kernel | wc -l` != 1 ]]; then
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