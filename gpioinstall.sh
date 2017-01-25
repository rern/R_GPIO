#!/bin/bash

# gpioinstall.sh - RuneUI GPIO
# https://github.com/rern/RuneUI_GPIO

# remove install files
# already installed
#		reinstall ?
#			exit
#			uninstall
# install
#		set mirror servers
#		Pip
#		python packages
#		check RuneUI enhancement
#			install
#		get gpiouninstall.sh
#		get tar.xz
#		backup
#		extract
#	remove tar.xz
#		set gpio default
# 		enable gpioset service
#		reload sudoers
# success (skip if reinstall with gpioinstall.sh)
#		clear opcache
#		Restart local browser
#		info

rm gpioinstall.sh

arg=$#

linered='\e[0;31m---------------------------------------------------------\e[m'
line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
warn=$( echo $(tput setab 1) ! $(tput setab 0) )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
runeenh=$( echo $(tput setaf 6)RuneUI Enhancement$(tput setaf 7) )
runegpio=$( echo $(tput setaf 6)RuneUI GPIO$(tput setaf 7) )
sync=0

# functions #######################################

title2() {
		echo -e "\n$line2\n"
		echo -e "$bar $1"
		echo -e "\n$line2\n"
}
title() {
		echo -e "\n$line"
		echo $1
		echo -e "$line\n"
}
titleend() {
		echo -e "\n$1"
		echo -e "\n$line\n"
}
error() {
		echo -e "\n$linered"
		echo $warn $1
		echo -e "$linered\n"
}
errorend() {
		echo -e "\n$warn $1"
		echo -e "\n$linered\n"
}

# check already installed #######################################

if grep -qs 'id="gpio"' /srv/http/app/templates/header.php; then
	title "$info $runegpio already installed."
	echo 'Reinstall' $runegpio':'
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 answer
	case $answer in
		1 ) ./gpiouninstall.sh re;; # with any argument to skip success message
		* ) echo
			titleend "$runegpio reinstall cancelled."
			rm gpioinstall.sh
			exit;;	
	esac
fi

# install packages #######################################

title2 "Install $runegpio ..."

[ ! -e /usr/bin/python ] && ln -s /usr/bin/python2.7 /usr/bin/python

if ! pacman -Q python2-pip > /dev/null 2>&1 || ! pacman -Q python-pip > /dev/null 2>&1; then
	if [ ! -e /var/cache/pacman/pkg/python2-pip-9.0.1-2-any.pkg.tar.xz ]; then
		title "Get packages file ..."
		wget -q --show-progress -O var.tar "https://github.com/rern/RuneUI_GPIO/blob/master/_repo/var.tar?raw=1"
		tar -xvf var.tar -C /
		rm var.tar
	fi
	title "Install Pip ..."
	pacman -S --noconfirm python2-pip
	ln -s /usr/bin/pip2 /usr/bin/pip
fi

if ! python -c "import mpd" > /dev/null 2>&1; then
	title "Install Python-MPD ..."
	pip install /var/cache/pacman/pkg/python-mpd2-0.5.5.tar.gz
fi
if ! python -c "import requests" > /dev/null 2>&1; then
	title "Install Python-Request ..."
	pip install /var/cache/pacman/pkg/requests-2.12.5-py2.py3-none-any.whl
fi

# check RuneUI enhancement #######################################

if ! grep -qs 'RuneUIe' /srv/http/app/templates/header.php; then
	echo -e "\nRequired $runeenh not found.\n"
	wget -q --show-progress -O install.sh "https://github.com/rern/RuneUI_enhancement/blob/master/install.sh?raw=1"
	chmod +x install.sh
	./install.sh gpio # with any argument to skip local browser restart and success message
fi

# get DAC config #######################################

if [ -f /etc/mpd.conf.gpio ]; then
		title "$info DAC configuration from previous install found."
		echo 'Discard:'
		echo -e '  \e[0;36m0\e[m Discard (new DAC)'
		echo -e '  \e[0;36m1\e[m Keep   (same DAC)'
		echo
		echo -e '\e[0;36m0\e[m / 1 ? '
		read -n 1 answer
		case $answer in
			1 ) echo;;
			* ) echo
					rm -v '/etc/mpd.conf.gpio';;
		esac
fi
if [ ! -f /etc/mpd.conf.gpio ]; then
	title "$info Get DAC configuration ready:"
	echo 'For external power DAC > power on'
	echo
	echo 'Menu > MPD > setup and verify DAC works properly before continue.'
	echo '(This install can be left running while setup.)'
	echo
	read -n 1 -s -p 'Press any key to continue ... '
	echo
fi

# install RuneUI GPIO #######################################

title "Get files ..."

wget -q --show-progress -O RuneUI_GPIO.tar.xz "https://github.com/rern/RuneUI_GPIO/blob/master/_repo/RuneUI_GPIO.tar.xz?raw=1"
wget -q --show-progress -O gpiouninstall.sh "https://github.com/rern/RuneUI_GPIO/blob/master/gpiouninstall.sh?raw=1"
chmod 755 gpiouninstall.sh

title "Backup existing files ..."
path='/srv/http/app/templates/'
file=$path'footer.php'
cp -v $file $file'.gpio'
file=$path'header.php'
cp -v $file $file'.gpio'

file='/etc/udev/rules.d/rune_usb-audio.rules'
cp -rfv $file $file'.gpio'
udevadm control --reload

if [ ! -f /etc/mpd.conf.gpio ]; then # skip if reinstall
	file='/etc/mpd.conf'
	cp -rfv $file $file'.gpio'
fi

title "Install files ..."
if [ ! -f /srv/http/gpio.json ]; then
	tar -Jxvf RuneUI_GPIO.tar.xz -C /
else
	tar -Jxvf RuneUI_GPIO.tar.xz -C / --exclude='srv/http/gpio.json' 
fi
rm RuneUI_GPIO.tar.xz

chmod -R 755 /etc/sudoers.d
chmod 755 /root/*.py
chmod 755 /srv/http/*.php
chown http:http /srv/http/gpio.json

./gpioset.py
systemctl enable gpioset

if [ $arg -eq 0 ]; then # skip if reinstall - gpioinstall.sh <arg>
	title "Clear PHP OPcache ..."
	curl '127.0.0.1/clear'
	echo

	if pgrep midori > /dev/null; then
		killall midori
		sleep 1
		startx  > /dev/null 2>&1 &
		echo -e '\nLocal browser restarted.\n'
	fi
	
	title2 "$runegpio successfully installed."
	echo $info 'Refresh browser and go to Menu > GPIO for settings.'
	titleend "To uninstall:   ./uninstall.sh"
fi
