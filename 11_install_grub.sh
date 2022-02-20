#!/bin/bash

set -Euo pipefail

grub-install --boot-directory=/boot --bootloader-id=ArchLinux_0 --target=x86_64-efi --efi-directory=/boot/grub2/x86_64-efi__nvme0n1p1 --removable --recheck
grub-install --boot-directory=/boot --bootloader-id=ArchLinux_1 --target=x86_64-efi --efi-directory=/boot/grub2/x86_64-efi__nvme1n1p1 --removable --recheck
grub-mkconfig -o /boot/grub/grub.cfg

