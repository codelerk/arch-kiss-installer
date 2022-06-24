#!/bin/bash

# Timezone Setup and Lang Setup

echo "Enter Timezone (ex. America/New_York)"
read -r timezone

echo

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

install_pkgs() {
	clear
	echo "Enter Additional Packages: "
	read -r pkgs

	pacman -S $pkgs --noconfirm
}

install_pkgs

# enable services
systemctl enable NetworkManager
systemctl enable dhcpcd
systemctl enable sshd

# User setup
echo "Enter Username: "
read -r uname
useradd -mG wheel $uname

echo

#set user password
echo "Set $uname password: "; passwd $uname
echo

#set root passwd
echo "Set Root password: "; passwd root
echo

# hostname setup
echo "Set Hostname: "
read -r hname
echo $hname > /etc/hostname

echo

grub_install() {
	echo "Enter the disk name (ex. /dev/sda): "
	read -r drive_name
	pacman -Syy grub efibootmgr --noconfirm
	grub-install $drive_name
	grub-mkconfig -o /boot/grub/grub.cfg
}

systemd_boot_install() {
	bootctl install
	echo -e "default arch.conf\ntimeout 10" > /boot/loader/loader.conf
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=/dev/sda2 rw" > /boot/loader/entries/arch.conf
}

# Choose your boot loader (Grub and Systemd boot are the only ones supported right now)

echo -e "1 Grub Boot Loader\n2 Systemd-Boot Loader\n"
echo "Choose Boot Loader: "
read -r boot_loader

case $boot_loader in
	1) grub_install ;;
	2) systemd_boot_install ;;
	*) grub_install ;;
esac
