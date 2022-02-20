#!/bin/bash

set -Euo pipefail

mkfs.fat -F32 /dev/nvme0n1p1
mkfs.fat -F32 /dev/nvme1n1p1
mkswap /dev/md2
mkfs.btrfs -f /dev/md3

