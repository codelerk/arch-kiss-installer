#!/bin/bash

timedatectl set-ntp true

echo "Hi Welcome to the Arch Kiss Installer!!!"
echo

echo "First thing we are going to do is partition the select disk we are installing Arch Linux onto!!!"
echo

lsblk
echo

echo -n "Enter Disk (ex. /dev/sda): "
read disk_drive

cfdisk $disk_drive
echo

lsblk
echo

echo -n "Enter Boot Partition (ex. /dev/sda1): "
read boot_partition
echo

echo -n "Enter Root Partition (ex. /dev/sda2): "
read root_partition
echo 

echo -n "Enter Swap Partition: (Leave this one empty, if no swap partition): "
read swap_partition

if [ "$swap_partition" != "" ]; then
	mkswap $swap_partition
	swapon $swap_partition
fi

echo

mkfs.ext4 $root_partition
mkfs.fat -F 32 $boot_partition

mount $root_partition /mnt
mount --mkdir $boot_partition /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware linux-headers dhcpcd networkmanager vim neofetch git openssh htop --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <(curl -s https://raw.githubusercontent.com/codelerk/arch-kiss-installer/main/chroot-install.sh)
