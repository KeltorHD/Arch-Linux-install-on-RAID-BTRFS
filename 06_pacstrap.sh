#!/bin/bash

set -Euo pipefail

pacman -S archlinux-keyring

pacstrap /mnt base linux linux-firmware grub grub-btrfs amd-ucode intel-ucode
pacstrap /mnt archlinux-keyring reflector dialog os-prober sudo vim tmux bash-completion wget
pacstrap /mnt efibootmgr mdadm btrfs-progs snapper snap-pac
pacstrap /mnt bridge-utils nftables firewalld openssh
pacstrap /mnt man-db man-pages texinfo
pacstrap /mnt git base-devel linux-headers bison flex bc
pacstrap /mnt mtools dosfstools exfat-utils
pacstrap /mnt mc htop atop sysstat strace iotop perf
