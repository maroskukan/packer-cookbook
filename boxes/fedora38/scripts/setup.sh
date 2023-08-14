#!/bin/bash -eux

printf "Setup stage.\n"

HYPERVISOR=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`


if [ "$HYPERVISOR" = "Microsoft Hyper-V" ]; then
  printf "Microsoft Hyper-V Detected.\n"
elif [ "$HYPERVISOR" = "VMware" ]; then
  printf "VMware Workstation Detected.\n"
  dnf install -y open-vm-tools
  systemctl enable --now vmtoolsd
elif [ "$HYPERVISOR" = "KVM" ]; then
  if [[ `cat /sys/devices/virtual/dmi/id/board_name` = "VirtualBox" ]]; then
    printf "Oracle VirtualBox Detected.\n"
    dnf install -y virtualbox-guest-additions
  fi
else
  printf "Unknown Hypervisor.\n"
fi