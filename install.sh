cli(){
	echo """
	==== Options ====
	(1) - partition drives
	(2) - format partition
	(3) - mount partitions
	(4) - unmount partions
	(5) - edit mirrorlist
	(6) - install base
	(7) - chroot
	Anything else to cancel
	"""
	read -n 1 input
	clear

	case $input in
		1) partition;;
		2) format;;
		3) mounting;;
		4) umount;;
		5) mirrorlist;;
		6) install;;
		7) chroot;;
		*) exit 0;;
	esac
	clear
	cli
	
}

pause(){
	read -t 5 -p "Press any key to continue..."
}

partition(){
	lsblk |  grep -v " 1 " | grep 'nvme[0-9]n[0-9] \|sd[a-z]'
	read disk
	cfdisk /dev/$disk
	clear
}

format(){
	lsblk -f
	read partition
	partition="/dev/$partition"
	clear

	echo $formatoptions
	read fs
	case $fs in
		swap) mkswap $partition;;
		*)    mkfs.$fs $partition;;
	esac

}

root_mount(){
	clear
	echo "---root partition---"
	lsblk -f
	read partition
	partition=/dev/$partition
	mount /dev/$partition /mnt
}

mounting(){
	root_mount
	askextra
}

askextra(){
	read -n 1 -p "Would like to mount additional partitions? (y/n)" input
	if [ $input = 'y' ]; then
		extra_mount
	fi
	clear
}

extra_mount(){
	mount
	echo "---extra partitions---"

	lsblk -f

	echo """
examples:
home
boot
swap
...
	"""

	read -p "mount point: " mount
	read -p "device: " partition

	if [[ $mount = swap ]]; then
		swapon $partition
	else
		mkdir /mnt/$mount
		mount $partition /mnt/$mount
	fi
	askextra
}

unmount(){
	umount -a
}

mirrorlist(){
	vim /etc/pacman.d/mirrorlist
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
	fstab /mnt > /mnt/etc/fstab
	cp /root/archinstall/config.sh /mnt/
	chmod 755 /mnt/config.sh
	arch-chroot /mnt /config.sh $cpuname
}

formatoptions="""
Format Options:
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
timedatectl set-ntp true
cli
