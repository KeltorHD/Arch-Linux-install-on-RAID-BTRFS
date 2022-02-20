#!/bin/bash

set -Euo pipefail

rm /mnt/etc/resolv.conf

genfstab -U /mnt >> /mnt/etc/fstab
sed -i 's/,subvolid=258,subvol=\/@\/.snapshots\/1\/snapshot//g' /mnt/etc/fstab
sed -i 's/rootflags=subvol=${rootsubvol} //g' /mnt/etc/grub.d/10_linux /mnt/etc/grub.d/20_linux_xen

mdadm --detail --scan --verbose >> /mnt/etc/mdadm.conf
sed -i 's/metadata=1.2 name=archiso:[23] //g' /mnt/etc/mdadm.conf

