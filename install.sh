#!/bin/bash

timedatectl set-ntp true

echo "Hi Welcome to the Arch Kiss Installer!!!"

echo

echo "First thing we are going to do is partition the select disk we are installing Arch Linux onto!!!"

echo

lsblk

echo

echo "Enter Disk (ex. /dev/sda): "
read -r disk_drive

cfdisk $disk_drive

echo "Enter Boot Partition (ex. /dev/sda1): "
read -r boot_partition

echo

echo "Enter Root Partition (ex. /dev/sda2): "
read -r root_partition

echo 

echo "Enter Swap Partition: "
read -r swap_partition

echo

mkfs.ext4 $root_partition
mkfs.fat -F 32 $boot_partition

mount $root_partition /mnt
mount --mkdir $boot_partition /mnt/boot

pacstrap /mnt base base-devel linux linux-firmware linux-headers dhcpcd networkmanager vim neofetch git openssh --noconfirm

genfstab -U /mnt >> /mnt/etc/fstab

wait arch-chroot /mnt /bin/bash <(curl -s https://raw.githubusercontent.com/codelerk/arch-kiss-installer/main/chroot-install.sh)

umount -R /mnt

reboot
