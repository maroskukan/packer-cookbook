#!/bin/bash -eux

printf "Setup stage.\n"

HYPERVISOR=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`


if [ "$HYPERVISOR" = "Microsoft Hyper-V" ]; then
  printf "Microsoft Hyper-V Detected.\n"
elif [ "$HYPERVISOR" = "vmware-iso" ]; then
  printf "VMware Workstation Detected.\n"
elif [ "$HYPERVISOR" = "virtualbox-iso" ]; then
  printf "Oracle VirtualBox Detected.\n"
  # Install tooling required for virtualization kernel modules
  dnf install -y kernel-tools kernel-devel kernel-headers
else
  printf "Unknown Hypervisor.\n"
fi