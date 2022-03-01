#!/bin/bash

set -Euo pipefail

mount /dev/md3 /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@/.snapshots
mkdir /mnt/@/.snapshots/1
btrfs subvolume create /mnt/@/.snapshots/1/snapshot

btrfs subvolume create /mnt/@/opt
btrfs subvolume create /mnt/@/root
btrfs subvolume create /mnt/@/srv
btrfs subvolume create /mnt/@/tmp
mkdir /mnt/@/usr
btrfs subvolume create /mnt/@/usr/local
btrfs subvolume create /mnt/@/var
btrfs subvolume create /mnt/@/home

cp files/info.xml /mnt/@/.snapshots/1/
btrfs subvolume set-default $(btrfs subvolume list /mnt | grep "@/.snapshots/1/snapshot" | grep -oP '(?<=ID )[0-9]+') /mnt
chattr +C /mnt/@/var

btrfs subvolume list /mnt
umount /mnt

mount /dev/md3 /mnt

mkdir /mnt/.snapshots
mkdir /mnt/opt
mkdir /mnt/root
mkdir /mnt/srv
mkdir /mnt/tmp
mkdir -p /mnt/usr/local
mkdir /mnt/var
mkdir /mnt/home

mkdir -p /mnt/boot/grub2/x86_64-efi__nvme0n1p1
mkdir -p /mnt/boot/grub2/x86_64-efi__nvme1n1p1

umount /mnt
