#/bin/bash

# Timezone Setup and Lang Setup

echo -n "Enter Timezone (ex. America/New_York): "
read zoneinfo

echo

ln -sf /usr/share/zoneinfo/$zoneinfo /etc/localtime
hwclock --systohc
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

enable_multilib() {
	sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
}

enable_multilib

install_pkgs() {
	clear
	echo -n "Enter Additional Packages: "
	read pkgs

	pacman -Syy $pkgs --noconfirm
}

install_pkgs

# enable services
systemctl enable NetworkManager
systemctl enable dhcpcd
systemctl enable sshd

# User setup
echo
echo -n "Enter Username: "
read uname
useradd -mG wheel $uname
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo

#set user password
echo "Set $uname password: "; passwd $uname
echo

#set root passwd
echo "Set Root password: "; passwd root
echo

# hostname setup
echo -n "Set Hostname: "
read hname
echo $hname > /etc/hostname
echo

yay() {
	# install yay by default
	git clone https://aur.archlinux.org/yay.git /home/$uname/yay
	chown -R $uname:$uname yay
}

yay

grub_install() {
	echo -n "Enter the disk name (ex. /dev/sda): "
	read drive_name
	pacman -Syy grub efibootmgr --noconfirm
	grub-install $drive_name
	grub-mkconfig -o /boot/grub/grub.cfg
}

systemd_boot_install() {
	echo -n "Enter Root Parition (ex. /dev/sda2): "
	read root_drive
	bootctl install
	echo -e "default arch.conf\ntimeout 3" > /boot/loader/loader.conf
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=$root_drive rw" > /boot/loader/entries/arch.conf
}

# Choose your boot loader (Grub and Systemd boot are the only ones supported right now)
echo
echo -e "1 Grub Boot Loader\n2 Systemd-Boot Loader\n"
echo -n "Choose Boot Loader: "
read boot_loader

case $boot_loader in
	1) grub_install ;;
	2) systemd_boot_install ;;
	*) grub_install ;;
esac
