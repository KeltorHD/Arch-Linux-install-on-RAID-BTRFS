#!/bin/bash

set -Euo pipefail

ln -s /usr/bin/vim /usr/bin/vi
ln -sf /usr/share/zoneinfo/US/Central /etc/localtime
hwclock --systohc

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf

cp -r files/etc/* /etc
chmod a-x /etc/hostname /etc/hosts /etc/systemd/network/*
systemctl enable systemd-networkd
systemctl enable systemd-resolved
systemctl enable sshd
systemctl enable nftables
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
sed -i 's/BINARIES=()/BINARIES=(\/sbin\/mdmon)/g' /etc/mkinitcpio.conf
sed -i 's/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck)/HOOKS=(base udev autodetect modconf block filesystems keyboard fsck mdadm_udev)/g' /etc/mkinitcpio.conf
mkinitcpio -p linux

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/g' /etc/sudoers

# Use with caution, this will disable CPU exploit mitigations for increased performance, ok for home use imho
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet mitigations=off/g' vi /etc/default/grub
