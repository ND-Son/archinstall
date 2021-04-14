partition(){

	echo $txtpartition
	lsblk | grep disk | grep -v " 1 "

	echo "Choose which disk to partition"
	read -p 'cfdisk /dev/' disk
	cfdisk /dev/$disk
	clear
}

format(){
	echo $txtformat

	lsblk -f
	echo "Choose partition to format"
	read -p '/dev/' partition
	clear

	echo "Choose its filesystem"
	echo $formatoptions
	read -p 'mkfs.' fs
	mkfs.$fs /dev/$partition
	clear

	echo "Choose its mount point"
	echo "enter nothing for root or 0 for swap"
	read mount
	if [$mount = 0]; then
		swapon /dev/$partition
	else
		mkdir /mnt$mount
		mount /dev/$partition /mnt$mount
	fi
}

install_base(){
	cpu='$(cat /proc/cpuinfo | grep vender | uniq | grep -o GenuineIntel)'
	case $cpu in
		GenuineIntel)  cpuname="intel" ;;
		*) cpuname="amd";;
	esac
	pacstrap /mnt base base-devel linux-firmware linux-zen linux-zen-headers xdg-user-dirs $cpuname-ucode
}

chroot(){
	cp /root/archinstall/config.sh /mnt/
	chmod 755 /mnt/config.sh
	arch-chroot /mnt /config.sh $cpuname
}

txtpartition="""
Partition
---------
"""

txtformat="""
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
swap
"""

cpuname=""
partition
timedatectl set-ntp true
genfstab -U /mnt >> /mnt/etc/fstab
chroot
