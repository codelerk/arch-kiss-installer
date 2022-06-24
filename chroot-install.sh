#!/bin/bash

# Timezone Setup and Lang Setup
ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# User setup
echo "Enter Username: "
read uname
useradd -mG wheel -s /usr/bin/fish $uname
echo "Set $uname password: "
passwd $uname


# root pass setup
echo "Set Root password: "
passwd root

# hostname setup
echo "Set Hostname: "
read hname
echo $hname > /etc/hostname

# Grub Installer
pacman -S grub efibootmgr
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg

echo "done installing....now exit and umount and you're ready to go"


# Systemd-boot installer
# echo -e "default arch.conf\ntimeout 10" > /boot/loader/loader.conf
# echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=/dev/sda2 rw" > /boot/loader/entries/arch.conf
