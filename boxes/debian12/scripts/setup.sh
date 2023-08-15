#!/bin/bash -eu

NAME_SH=setup.sh

echo "==> ${NAME_SH}: Setup stage start.."

HYPERVISOR=`dmesg | grep "Hypervisor detected" | awk -F': ' '{print $2}'`


if [ "${HYPERVISOR}" = "Microsoft Hyper-V" ]; then
  echo "==> ${NAME_SH}: Microsoft Hyper-V Detected.."
elif [ "${HYPERVISOR}" = "VMware" ]; then
  echo "==> ${NAME_SH}: VMware Workstation Detected.."

  echo "==> ${NAME_SH}: Installing and enabling Open VM Tools.."
  apt-get install -y open-vm-tools
  systemctl enable --now vmtoolsd
elif [ "${HYPERVISOR}" = "KVM" ]; then
  if [[ `cat /sys/devices/virtual/dmi/id/board_name` = "VirtualBox" ]]; then
    echo "==> Oracle VirtualBox Detected.."

    echo "==> ${NAME_SH}: Downloading build build tools.."
    apt-get install -y linux-headers-$(uname -r) gcc make perl

    echo "==> ${NAME_SH}: Downloading and installing Guest Additions.."
    wget -q https://download.virtualbox.org/virtualbox/7.0.10/VBoxGuestAdditions_7.0.10.iso
    mount VBoxGuestAdditions_7.0.10.iso /media
    /media/VBoxLinuxAdditions.run || echo "VBoxLinuxAdditions.run exit code $? is suppressed";
    
    echo "==> ${NAME_SH}: Unmounting and removing the iso and build tools.." 
    umount /media
    rm -rf VBoxGuestAdditions_7.0.10.iso
    apt-get purge -y linux-headers-$(uname -r) gcc make perl

    echo "==> ${NAME_SH}: Applying fix for BdsDxe: Failed to load Boot0001"
    echo 'FS0:\\EFI\\debian\\grubx64.efi' > /boot/efi/startup.nsh
    #mkdir -p /boot/efi/EFI/BOOT
    #cp /boot/efi/EFI/debian/grubx64.efi /boot/efi/EFI/BOOT/bootx64.efi
  fi
else
  echo "${NAME_SH}: Unknown Hypervisor..\n"
fi
sleep 60
echo "==> Setup stage end.."