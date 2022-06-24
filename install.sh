#!/bin/bash

timedatectl set-ntp true

mount /dev/sda1 /mnt
mount --mkdir /dev/sda2 /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware linux-headers dhcpcd networkmanager fish

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <(curl -s https://raw.githubusercontent.com/codelerk/arch-install/main/chroot-install.sh)
