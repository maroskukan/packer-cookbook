#!/usr/bin/env bash

set -e
if [ -n "$BUILD_DEBUG" ] && set -x

NAME_SH=setup.sh

echo "==> ${NAME_SH}: Setup stage start.."

# Hypervisor Specific Packages
HYPERVISOR=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`


if [ "$HYPERVISOR" = "Microsoft Hyper-V" ]; then
  echo "==> ${NAME_SH}: Microsoft Hyper-V Detected.."
  echo "==> ${NAME_SH}: Installing rsync.."
  dnf install -y rsync
elif [ "$HYPERVISOR" = "VMware" ]; then
  echo "==> ${NAME_SH}: VMware Workstation Detected.."
  echo "==> ${NAME_SH}: Installing and enabling Open VM Tools.."
  dnf install -y open-vm-tools
  systemctl enable --now vmtoolsd
elif [ "$HYPERVISOR" = "KVM" ]; then
  if [[ `cat /sys/devices/virtual/dmi/id/board_name` = "VirtualBox" ]]; then
    echo "==> Oracle VirtualBox Detected.."
    echo "==> ${NAME_SH}: Installing VirtualBox Guest Additions.."
    dnf install -y virtualbox-guest-additions
  fi
else
  echo "==> ${NAME_SH}: Unknown Hypervisor.."
fi
echo "==> Setup stage end.."