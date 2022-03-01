#!/bin/bash

set -Euo pipefail

mount /dev/md3 /mnt

mount -o subvol=@/.snapshots /dev/md3 /mnt/.snapshots
mount /dev/nvme0n1p1 /mnt/boot/grub2/x86_64-efi__nvme0n1p1
mount /dev/nvme1n1p1 /mnt/boot/grub2/x86_64-efi__nvme1n1p1
mount -o subvol=@/opt /dev/md3 /mnt/opt
mount -o subvol=@/root /dev/md3 /mnt/root
mount -o subvol=@/srv /dev/md3 /mnt/srv
mount -o subvol=@/tmp /dev/md3 /mnt/tmp
mount -o subvol=@/usr/local /dev/md3 /mnt/usr/local
mount -o subvol=@/var /dev/md3 /mnt/var
mount -o subvol=@/home /dev/md3 /mnt/home

swapon /dev/md2

chattr +C /mnt/var

