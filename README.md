# Installation of Arch Linux on RAID with the BTRFS filesystem

### Mount USB drive containing instalation scripts in the 'arch_install' directory 
Assuming here that /dev/sda is USB stick containing arch linux installation and /dev/sdb contains our configuration scripts
```
mkdir /store
mount /dev/sdb1 /store
cd /store/arch_install
```

### Create RAID setup
```
./01_create_partitions.sh
./02_create_raid.sh
```

### Create filesystems
```
./03_create_filesystems.sh
./04_configure_btrfs.sh
./05_mount_btrfs.sh
```

### Download system files
```
./06_pacstrap.sh
```

### Create fstab and mdadm config, remove resolv.conf
```
./07_pre_chroot.sh
```

### Chroot into the new filesystem
```
cd
umount /store
arch-chroot /mnt
mount /dev/sdb1 /mnt
cd /mnt/arch_install
```

### Setup timezone, language, ntworking, create ramdrive, update suders config
```
./10_post_chroot.sh
```

### Install grub
```
./11_install_grub.sh
```

### Setup snapper
```
./12_setup_snapper.sh
```

### Setup root password and reboot
```
passwd
exit
reboot
```

### Logn into freshly installed system and make the snapshot
```
snapper -c root create --description 'Initial install, CLI only'
```





# Old procedure - deprecated

## Prepare drives
```
dd if=/dev/zero of=/dev/nvme0n1 bs=512 count=1
dd if=/dev/zero of=/dev/nvme1n0 bs=512 count=1
sgdisk -z /dev/nvme0n1
sgdisk -z /dev/nvme1n1
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:'EFI' /dev/nvme0n1
sgdisk -n 2:0:+8G -t 2:fd00 -c 2:'RAID [swap]' /dev/nvme0n1
sgdisk -n 3:0:0 -t 3:fd00 -c 3:'RAID [system]' /dev/nvme0n1
sgdisk /dev/nvme0n1 -R /dev/nvme1n1 -G
reboot
```

## Create RAID
```
mdadm --create /dev/md0 --level=1 --raid-disks=2 /dev/nvme[01]n1p2
mdadm --create /dev/md1 --level=1 --raid-disks=2 /dev/nvme[01]n1p3
```

## Create filesystems
```
mkfs.fat -F32 /dev/nvme0n1p1
mkfs.fat -F32 /dev/nvme1n1p1
mkswap /dev/md0
swapon /dev/md0
mkfs.btrfs /dev/md1
```

## Install Arch Linux
```
timedatectl set-ntp true
```

```
mount /dev/md1 /mnt
btrfs subvolume create /mnt/@
brtfs subvolume create /mnt/@boot
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@var
btrfs subvolume create /mnt/@tmp
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@opt
btrfs subvolume create /mnt/@snapshots
umount /mnt
```

```
mount -o subvol=@ /dev/md1 /mnt
mkdir /mnt/{boot,root,var,tmp,home,opt}
mount -o subvol=@root /dev/md1 /mnt/root
mount -o subvol=@var /dev/md1 /mnt/var
mount -o subvol=@tmp /dev/md1 /mnt/tmp
mount -o subvol=@home /dev/md1 /mnt/home
mount -o subvol=@opt /dev/md1 /mnt/opt
mount -o subvol=@boot /dev/md1 /mnt/boot
mkdir -p /mnt/boot/grub2/x86_64-efi__nvme{01}n1p1
mount /dev/nvme0n1p1 /mnt/boot/grub2/x86_64-efi__nvme0n1p1
mount /dev/nvme1n1p1 /mnt/boot/grub2/x86_64-efi__nvme1n1p1
```

```
pacstrap /mnt base linux linux-firmware vim grub grub-btfs efibootmgr mdadm amd-ucode btrfs-progs
genfstab -U /mnt >> /mnt/etc/fstab
mdadm --detail --scan --verbose   >>   /mnt/etc/mdadm.conf
```

```
vim /mnt/etc/mdadm.conf 
  # At the end of this file uncomment PROGAM line and remove metadata & name from ARRAY lines
```

```
arch-chroot /mnt
ln -s /usr/bin/vim /usr/bin/vi
passwd
ln -sf /usr/share/zoneinfo/US/Eastern /etc/localtime
hwclock —systohc
```

```
vim /etc/locale.gen
  # uncomment line starting with '# en_US.UTF-8 UTF-8'
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf
```

```
echo blackbox > /etc/hostname
echo '127.0.0.1	localhost' >> /etc/hosts
echo '::1		localhost' >> /etc/hosts
echo '127.0.1.1	blackbox.local	blackbox' >> /etc/hosts
```

```
vi /etc/mkinitcpio.conf
  # Update line 'MODULES=(btrfs)'
  # Update line 'BINARIES=(/sbin/mdmon)'
  # Update line 'HOOKS=(mdadm_udev)'

mkinitcpio -p linux
```

```
pacman -S base-devel linux-headers dialog os-prober mtools dosfstools reflector git snapper bridge-utils man-db man-pages
```

```
grub-install --boot-directory=/boot --bootloader-id=ArchLinux_0 --target=x86_64-efi --efi-directory=/boot/grub2/x86_64-efi__nvme0n1p1 --emovable --recheck
grub-install --boot-directory=/boot --bootloader-id=ArchLinux_1 --target=x86_64-efi --efi-directory=/boot/grub2/x86_64-efi__nvme1n1p1 --emovable --recheck
grub-mkconfig -o /boot/grub/grub.cfg
```

## Install networking (bridge for VMs)
```
systemctl enable systemd-networkd
systemctl enable systemd-resolved
ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

```
vim /etc/systemd/network/enp5s0.network

[Match]
Name=enp4s0

[Network]
Bridge=br0
```

```
vim /etc/systemd/network/br0.netdev
[NetDev]
Name=br0
Kind=bridge
```

```
vim /etc/systemd/network/br0.network
[Match]
Name=br0

[Network]
DNS=192.168.250.1
Address=192.168.250.33/24
Gateway=192.168.250.1
```

## Setup snapper
```
snapper -c root create-config /
btrfs subvolume delete /.snapshots
mkdir /.snapshots
mount -o subvol=@snapshots /dev/md1p1 /.snapshots
  # Add entry to fstab
snapper -c root create —description 'initial installation'
```

## Add user
```
useradd -mG wheel herman
passwd herman
visudo
  # Uncomment line '# %wheel ALL=(ALL) ALL'
```

## Install gnome
```
pacman -Syu
pacman -S xorg xorg-server gnome ttf-lberation firefox gnome-tweaks
systemctl enable gdm.service
reboot
```

## Install nvidia drives (from herman user in gnome)
```
pacman -S nvidia
echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf
mkdir -p /etc/pacman/hooks
```

```
vi /etc/pacman.d/hooks/nvidia.hook

[Trigger]
Operation=Install
Operation=Upgrade
Operation=Remove
Type=Package
Target=nvidia
Target=linux
[Action]
Description=Update Nvidia module in initcpio
Depends=mkinitcpio
When=PostTransaction
NeedsTargets
Exec=/bin/sh -c 'while read -r trg; do case $trg in linux) exit 0; esac; done; /usr/bin/mkinitcpio -P'
```

```
vi /etc/X11/xorg.conf.d/10-nvidia.conf

Section "OutputClass"
Identifier "nvidia"
MatchDriver "nvidia-drm"
Driver "nvidia"
Option "AllowEmptyInitialConfiguration"
Option "PrimaryGPU" "yes"
ModulePath "/usr/lib/nvidia/xorg"
ModulePath "/usr/lib/xorg/modules"
EndSection
```

```
vi /etc/mkinitcpio.conf
  # Update line 'MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)'

mkinitcpio -p linux

snapper -c root create —description 'initial installation + gui'
```
