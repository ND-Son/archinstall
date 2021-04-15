name=""
cli(){
	echo """
	==== Options ====
	(1) - Timezone
	(2) - Localization
	(3) - Network
	(4) - Administration
	(5) - Bootloader
	(6) - AUR
	Anything else to cancel
	"""
	read -n 1 input
	clear

	case $input in
		1) timezone;;
		2) localization;;
		3) network;;
		4) administration;;
		5) bootloader;;
		6) aur;;
		*) exit 0;;
	esac
	clear
	cli
}

network(){
	echo """
	LAN only? (y/n)
	"""
	read -n 1 input

	case $input in
		y)
			pacman -S dhcpcd
			systemctl enable dhcpcd 
			;;
		*)
			pacman -S networkmanager
			systemctl enable NetworkManager
			;;
	esac

}
timezone(){
	cd /usr/share/zoneinfo/
	ls -d */
	read -p "Type your region: " region

	cd $region
	ls
	read -p "Enter City:" city

	ln -sf $city /etc/localtime
	cd /
	hwclock --systohc
}

localization(){
	# locale gen
	echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
	locale-gen

	# locale.conf
	echo "LANG=en_US.UTF-8" > /etc/locale.conf

}

administration(){
	
	# root paswd
	passwd 

	# hostname
	read -p "Hostname:" name

host="""
127.0.0.1 	localhost
::1 		localhost
127.0.1.1 	$name.localdomain $name
"""

	echo $host > /etc/hosts

	echo "set user password"
	passwd $name

	echo "creating User"
	read -p "name" $name
	useradd -m $name
	passwd son
	usermod -aG wheel,audio,video,storage,optical $name
	echo "%wheel ALL=(ALL) ALL" > /etc/sudoers
}

bootloader(){
	# check if it is an efi system
	efi='$(ls /sys/firmware/ | grep efi)'

	case $efi in
		efi) 		systemd_boot;;
		*) 		grub;;
	esac
}

grub(){
	pacman -S grub os-prober
	clear
	echo "Choose disk target"
	lsblk | grep disk
	read -p "/dev/" disk
	grub-install --target=i386-pc /dev/$disk
	grub-mkconfig -o /boot/grub/grub.cfg
}

systemd_boot(){
	bootctl --path=/boot install
	rm /boot/loader/loader.conf
	echo "default arch-*" > /boot/loader/loader.conf
	echo "editor no" > /boot/loader/loader.conf
	fstabstr='$(cat /etc/fstab | grep '/ ')'
	UUID=${fstabstr:4:35}
echo """
title Arch Linux
linux /vmlinuz-linux-zen
initrd /$1-ucode.img
initrd /initramfs-linux-zen.img
options root=UUID=$UUID rw
""" > /boot/loader/entries/arch.conf
}

aur(){
	cd /home/$name
	git clone https://aur.archlinux.org/paru
	cd paru
	sudo -u $name -g wheel makepkg -si
	cd /
}

efstab(){
	vim /etc/fstab
}

cli
rm /config.sh
