#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
	echo "please run as root!"
	exit 1
fi

if [[ $(cat /sys/module/loop/parameters/max_loop) = 0 ]]; then
	echo "no loop devices in the system!";
	# run below to enable it on ubuntu
	# sudo sed -i "/GRUB_CMDLINE_LINUX=/c\GRUB_CMDLINE_LINUX=\"max_loop=255\"" /etc/default/grub
	# sudo update-grub
	# reboot
    exit 1
fi

if [ "$#" -ne 2 ]; then
	echo "wrong number of parameters passed!";
	echo "usage: sudo ./create-image raspbian.img wifi_module";
	echo "supported wifi: BCM43143 (rasp 3 build-in), tl-wn725n";
    exit 1
fi

if [ ! -e  $1 ]; then
	echo image file not found: $1
	exit 1;
fi

if [[ "$2" != BCM43143 && "$2" != tl-wn725n ]]; then
	echo wifi not supported: $2
	exit 1;
fi

if [ ! -e  "./dist/bin" ]; then
	mkdir ./dist/bin
fi

if [ ! -e  "./mnt" ]; then
	mkdir ./mnt
fi

if [ ! -e  "./boot" ]; then
	mkdir ./boot
fi

# offset is calculated by $ sudo kpartx -av 2017-01-11-raspbian-jessie.img  
# add map loop5p1 (252:0): 0 129024 linear 7:5 8192
# add map loop5p2 (252:1): 0 8400896 linear 7:5 137216
# 8192 * 512 = 4194304
# 137216 * 512 =70254592

sudo mount -v -o offset=4194304 -t msdos $1 ./boot
touch ./boot/ssh
umount ./boot

sudo mount -v -o offset=70254592 -t ext4 $1 ./mnt
mkdir ./mnt/temp/
mkdir ./mnt/temp/bin
mkdir ./mnt/var/www

./scripts/webpage.sh
cp ./dist/webpage/index.html ./mnt/var/www/index.html
cp ./dist/webpage/server.py ./mnt/usr/local/bin/tinyweb
chmod 755 ./mnt/usr/local/bin/tinyweb

./scripts/packages.sh ./mnt
cp ./dist/udhcpd.conf ./mnt/temp/udhcpd.conf
cp ./dist/udhcpd ./mnt/temp/udhcpd

if [ "$2" = "tl-wn725n" ]; then
	if [ ! -e  ./dist/bin/hostapd ]; then
		wget -O ./dist/bin/hostapd.zip http://www.daveconroy.com/wp3/wp-content/uploads/2013/07/hostapd.zip 
		unzip ./dist/bin/hostapd.zip -d ./dist/bin/
	fi
	cp ./dist/bin/hostapd ./mnt/temp/bin/hostapd
fi

cp ./dist/hostapd.conf ./mnt/temp/hostapd.conf
cp ./dist/hostapd ./mnt/temp/hostapd
cp ./dist/interfaces ./mnt/temp/interfaces
mv ./mnt/etc/rc.local ./mnt/etc/rc.local.bak
cp ./dist/rc.local ./mnt/etc/rc.local
chmod 755 ./mnt/etc/rc.local
touch ./mnt/temp/wificonf

sudo umount ./mnt
