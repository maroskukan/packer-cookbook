#!/bin/bash -eux

printf "Update stage.\n"

# Upgrade packages
dnf upgrade -y

# Boot to new kernel if applicable
if [[ `rpm -q kernel | wc -l` != 1 ]]; then
  printf "Multiple kernels available. Will reboot.\n"
  ( shutdown --reboot --no-wall +1 ) &
  exit 0
else
 printf "One kernel found. Reboot skipped.\n"
 exit 0
fi