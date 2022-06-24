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
	echo -e "[multilib]\nInclude = /etc/pacman.d/mirrorlist" >> /etc/pacman.conf
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
echo -e "%wheel ALL=(ALL:ALL) NOPASSWD ALL" >> /etc/sudoers
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

install_yay() {
	# install yay by default
	git clone https://aur.archlinux.org/yay.git
	chown -R $uname:$uname yay
	cd yay
	su $uname -c "sudo pacman -S go --noconfirm; makepkg -si"
	cd ..
	rm -r yay
}

install_yay

# reset sudo access to password without a password
sed -i '$ d' /etc/sudoers
echo -e "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers

grub_install() {
	echo -n "Enter the disk name (ex. /dev/sda): "
	read drive_name
	pacman -Syy grub efibootmgr --noconfirm
	grub-install $drive_name
	grub-mkconfig -o /boot/grub/grub.cfg
}


systemd_boot_install() {
	bootctl install
	echo -e "default arch.conf\ntimeout 5" > /boot/loader/loader.conf
	echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=/dev/sda2 rw" > /boot/loader/entries/arch.conf
}

# Choose your boot loader (Grub and Systemd boot are the only ones supported right now)

echo -e "1 Grub Boot Loader\n2 Systemd-Boot Loader\n"
echo -n "Choose Boot Loader: "
read boot_loader

case $boot_loader in
	1) grub_install ;;
	2) systemd_boot_install ;;
	*) grub_install ;;
esac
