#!/bin/bash

set -Euo pipefail

pacman -S xorg xorg-server
pacman -S plasma kde-applications
pacman -S ttf-liberation ttf-fira-code
pacman -S firefox
pacman -S flatpak

systemctl enable sddm.service
