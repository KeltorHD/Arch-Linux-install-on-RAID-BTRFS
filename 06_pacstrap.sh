#!/bin/bash

set -Euo pipefail

pacstrap /mnt base linux linux-firmware
pacstrap /mnt vim grub grub-btrfs efibootmgr mdadm amd-ucode btrfs-progs sudo os-prober snapper snap-pac reflector openssh nftables
pacstrap /mnt git man-db man-pages texinfo exfat-utils base-devel linux-headers dialog os-prober mtools dosfstools bridge-utils archlinux-keyring

