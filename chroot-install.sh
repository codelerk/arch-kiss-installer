#!/bin/bash

echo "Enter Username: "
read uname

ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

hwclock --systohc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen

useradd -mG wheel -s /usr/bin/fish $uname

echo "Set $uname password: "
passwd $uname

echo "Set Root password: "
passwd root

echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "Set Hostname: "
read hname

echo $hname > /etc/hostname

echo -e "default arch.conf\ntimeout 10" > /boot/loader/loader.conf

echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=/dev/sda2 rw" > /boot/loader/entries/arch.conf
