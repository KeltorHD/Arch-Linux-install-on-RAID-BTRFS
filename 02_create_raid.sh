#!/bin/bash

set -Euo pipefail

mdadm --create /dev/md2 --level=1 --raid-disks=2 /dev/nvme[01]n1p2
mdadm --create /dev/md3 --level=1 --raid-disks=2 /dev/nvme[01]n1p3

