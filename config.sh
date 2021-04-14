# set root password

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
	vim /etc/locale.gen
	locale-gen

	# locale.conf
	echo "LANG=en_US.UTF-8" > /etc/locale.conf

	# hostname
	read -p "Hostname:" name

host="""
127.0.0.1 	localhost
::1 		localhost
127.0.1.1 	$name.localdomain $name
"""

	echo $host > /etc/hosts
}

administration(){
	echo "set user password"
	passwd

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
	grup-install --target=i386-pc /dev/$disk
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

timezone
localization
administration
bootloader
