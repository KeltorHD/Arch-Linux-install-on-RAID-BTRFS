#!/bin/bash

set -Euo pipefail

sgdisk -z /dev/nvme0n1
sgdisk -z /dev/nvme1n1

sgdisk -n 1:0:+512M -t 1:ef00 -c 1:'EFI' /dev/nvme0n1
sgdisk -n 2:0:+8G -t 2:fd00 -c 2:'RAID [swap]' /dev/nvme0n1
sgdisk -n 3:0:0 -t 3:fd00 -c 3:'RAID [system]' /dev/nvme0n1
sgdisk /dev/nvme0n1 -R /dev/nvme1n1 -G

fdisk -l /dev/nvme0n1
fdisk -l /dev/nvme1n1
