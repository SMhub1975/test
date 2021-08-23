#!/bin/bash

timedatectl set-ntp true

partprobe

cryptsetup --cipher=aes-xts-plain64 --offset=0 --key-file=/dev/sdb2 --key-size=512 open --type plain /dev/sda cryptlvm

pvcreate /dev/mapper/cryptlvm

vgcreate cryptvol /dev/mapper/cryptlvm

lvcreate -L 1G cryptvol -n swap
lvcreate -L 6G cryptvol -n root
lvcreate -l 100%FREE cryptvol -n home

mkfs.ext4 /dev/cryptvol/root
mkfs.ext4 /dev/cryptvol/home
mkswap /dev/cryptvol/swap

mount /dev/cryptvol/root /mnt
mkdir /mnt/home
mount /dev/cryptvol/home /mnt/home
swapon /dev/cryptvol/swap

mkfs.ext4 /dev/sdb1
mkfs.ext4 /dev/sdb2
mkdir /mnt/boot
mount /dev/sdb1 /mnt/boot

pacstrap /mnt base linux lvm2

genfstab -U /mnt >> /mnt/etc/fstab

curl https://raw.githubusercontent.com/SMhub1975/arch/master/archi2.sh > /mnt/archi2.sh && arch-chroot /mnt bash archi2.sh && rm /mnt/archi2.sh

###############################################################################################################################################

# cryptsetup open --type luks /dev/sda2 cryptlvm
# mount /dev/cryptvol/root /mnt
# mount /dev/sda1 /mnt/boot
# vim /etc/mkinitcpio.conf___HOOKS=(base udev autodetect keyboard keymap consolefont modconf block encrypt lvm2 filesystems fsck)
# vim /etc/default/grub___cryptdevice=UUID=UUID-del-dispositivo:cryptlvm root=/dev/cryptvol/root
# mkinitcpio -p linux
# grub-mkconfig -o /boot/grub/grub.cfg


