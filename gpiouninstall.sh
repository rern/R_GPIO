#!/bin/bash

# gpiouninstall.sh - RuneUI GPIO
# https://github.com/rern/RuneUI_GPIO

# (called by uninstall.sh)
# not installed
#		exit
# uninstall
#		remove files
#		disable service
#		remove gpio data
#		restore files
# success (skip if install with gpioinstall.sh)
#		clear opcache
#		info
# remove install files

arg=$#

linered='\e[0;31m---------------------------------------------------------\e[m'
line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
warn=$( echo $(tput setab 1) ! $(tput setab 0) )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
runeenh=$( echo $(tput setaf 6)RuneUI Enhancement$(tput setaf 7) )
runegpio=$( echo $(tput setaf 6)RuneUI GPIO$(tput setaf 7) )

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

# check installed #######################################

if ! grep -qs 'id="gpio"' /srv/http/app/templates/header.php; then
	title "$info $runegpio not found."
	exit
fi

# gpio off #######################################
./gpiooff.py  > /dev/null 2>&1 &

title2 "Uninstall $runegpio ..."

title "$runegpio installed packages"
echo 'Uninstall:'
echo -e '  \e[0;36m0\e[m Uninstall'
echo -e '  \e[0;36m1\e[m Keep'
echo
echo -e '\e[0;36m0\e[m / 1 ? '
read -n 1 answer
case $answer in
	1 ) echo;;
	* ) echo
			title "Uninstall packages ..."
			pip2 uninstall -y python-mpd2
			pip2 uninstall -y requests
			pacman -Rs --noconfirm python2-pip
			rm /usr/bin/python
esac

title "Remove files ..."

rm -v /root/gpiooff.py
rm -v /root/gpioon.py
rm -v /root/gpioset.py
rm -v /root/gpiostatus.py
rm -v /root/gpiotimer.py
rm -v /root/poweroff.py
rm -v /root/reboot.py

rm -v /srv/http/gpiooff.php
rm -v /srv/http/gpioon.php
rm -v /srv/http/gpiosave.php
rm -v /srv/http/gpiosettings.php
rm -v /srv/http/gpiostatus.php
rm -v /srv/http/gpiotimerreset.php
rm -v /srv/http/poweroff.php
rm -v /srv/http/reboot.php
rm -v /srv/http/assets/css/gpiosettings.css
rm -v /srv/http/assets/js/gpio.js
rm -v /srv/http/assets/js/gpiosettings.js
rm -v /srv/http/assets/js/vendor/bootstrap-select-1.12.1.min.js

title "Remove service ..."
systemctl disable gpioset
rm -v /usr/lib/systemd/system/gpioset.service

title "Restore backup files ..."
path='/srv/http/app/templates/'
file=$path'footer.php'
mv -v $file'.gpio' $file
file=$path'header.php'
mv -v $file'.gpio' $file

file='/etc/mpd.conf'
cp -rfv $file'.pacorig' $file
file='/etc/pacman.d/mirrorlist'
cp -fv $file'.original' $file
file='/etc/udev/rules.d/rune_usb-audio.rules'
mv -fv $file'.gpio' $file
rm -vrf /etc/sudoers.d
udevadm control --reload

if [ $arg -eq 0 ]; then # skip if reinstall - gpiouninstall.sh <arg>
	title "Clear PHP OPcache ..."
	curl '127.0.0.1/clear'
	echo

	title2 "$runegpio successfully uninstalled."
	titleend "$info Refresh browser for default $runeenh."
fi

rm gpiouninstall.sh
