#!/bin/bash

# uninstall_gpio.sh - RuneUI GPIO
# https://github.com/rern/RuneUI_GPIO

# (called by uninstall.sh)
# not installed
#	exit
# uninstall
#	remove files
#	disable service
#	remove gpio data
#	restore files
# success
#	clear opcache
#	restart local browser
#	info
# remove uninstall_gpio.sh

# import heading function
wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh
runegpio=$( tcolor "RuneUI GPIO" )

# check installed #######################################
if [[ ! -e /srv/http/assets/css/gpiosettings.css ]]; then
	echo -e "$info $runegpio not found."
	exit
fi

# gpio off #######################################
./gpiooff.py &>/dev/null &

title -l = "$bar Uninstall $runegpio ..."
# uninstall packages #######################################
echo -e "$bar Remove installed packages ..."
pacman -Q python2-pip &>/dev/null && pip='Python-Pip,' || pip=''
yesno "Uninstall $pip Python-MPD and Python-Requests:" answer
if [[ $answer == 1 ]]; then
		echo -e "$bar Uninstall packages ..."
		pip uninstall -y python-mpd2 requests
		if pacman -Q python2-pip &>/dev/null; then
			pacman -Rs --noconfirm python2-pip
			rm /usr/bin/pip
		fi
fi

# remove files #######################################
echo -e "$bar Remove files ..."
rm -v /root/{gpiooff.py,gpioon.py,gpiotimer.py,poweroff.py,reboot.py}
rm -v /srv/http/{gpiooff.php,gpioon.php,gpiosave.php,gpiosettings.php,gpiostatus.php,gpiotimerreset.php,poweroff.php,reboot.php}
path=/srv/http/assets
rm -v $path/css/gpiosettings.css
rm -v $path/img/RPi3_GPIOs.png
rm -v $path/js/{gpio.js,gpiosettings.js}
rm -v $path/js/vendor/bootstrap-select-1.12.1.min.js

# if RuneUI enhancement not installed
[[ -e $path/css/custom.css ]] && enh=true || enh=false
if ! $enh; then
	rm -v $path/css/pnotify.css
	rm -v $path/js/vendor/pnotify3.custom.min.js
fi

# restore modified files #######################################
echo -e "$bar Restore modified files ..."
header=/srv/http/app/templates/header.php
echo $header
sed -i -e '\|<?php // gpio|, /?>/ d
' -e '/id="ond"/, /id="offd"/ d
' -e '/id="gpio"/ d
' -e '/gpiosettings.php/ d
' $header
# no RuneUI enhancement
! $enh && sed -i -e '/pnotify.css/ d' $header

footer=/srv/http/app/templates/footer.php
echo $footer
sed -i -e 's/id="poweroff"/id="syscmd-poweroff"/
' -e 's/id="reboot"/id="syscmd-reboot"/
' -e '/gpio.js/ d
' $footer
# no RuneUI enhancement
! $enh && sed -i -e '/pnotify3.custom.min.js/ d' $footer

# Dual boot
sed -i -e '/^#"echo/ s/^#//g
' -e '/reboot.py/d
' /root/.xbindkeysrc

cp -vf /etc/mpd.conf{.pacorig,}
systemctl restart mpd

udev=/etc/udev/rules.d/rune_usb-audio.rules
echo $udev
sed -i '/SUBSYSTEM=="sound"/ s/^#//' $udev
udevadm control --reload

echo -e "$bar Remove service ..."
systemctl disable gpioset
systemctl daemon-reload
rm -v /etc/sudoers.d/http /etc/systemd/system/gpioset.service

# skip if reinstall - gpiouninstall.sh re (any argument)
(( $# != 0 )) && exit

# refresh #######################################
echo -e "$bar Clear PHP OPcache ..."
curl '127.0.0.1/clear'
echo

if pgrep midori >/dev/null; then
	killall midori
	sleep 1
	xinit &>/dev/null &
	echo -e '\nLocal browser restarted.\n'
fi

title -l = "$bar $runegpio uninstalled successfully."
title -nt "$info Refresh browser for no $runegpio."

rm $0