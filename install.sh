partition(){

	echo $txtpartition
	lsblk | grep disk | grep -v " 1 "

	echo "Choose which disk to partition"
	read -p 'cfdisk /dev/' disk
	cfdisk /dev/$disk
}

format(){
	echo $txtformat

	lsblk -f
	echo "Choose partition to format"
	read -p '/dev/' partition

	echo "Choose its filesystem"
	echo $formatoptions
	read -p 'mkfs.' fs
	mkfs.$fs /dev/$partition

	echo "Choose its mount point (enter nothing for swap)"
	read mount
	mkdir /mnt$mount
	mount $partition /mnt$mount
}

install_base(){
	cpu='$(cat /proc/cpuinfo | grep vender | uniq | grep GenuineIntel)'
	case $cpu in
		GenuineIntel)  cpuname="intel" ;;
		*) cpuname="amd";;
	esac
	pacstrap /mnt base base-devel linux-firmware linux-zen linuz-zen-headers xdg-user-dirs $cpuname-ucode
	clear
}

chroot(){
	cp /archinstall/config.sh /mnt/root
	chmod +x /mnt/root/config.sh
	arch-chroot /mnt /mnt/root/config.sh $cpuname
}

txtpartition="""
Partition
---------
"""

txtformat"""
Formatting
----------
"""

formatoptions="""
Options:
ext4
btrfs
xfs
exfat
vfat
f2fs
zfs
"""

cpuname=""
timedatectl ntp-set true
partition
format
install_base
genfstab -U /mnt >> /mnt/etc/fstab
chroot
