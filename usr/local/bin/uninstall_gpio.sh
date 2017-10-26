#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh

# gpio off #######################################
./gpiooff.py &> /dev/null &

uninstallstart $@

# remove files #######################################
echo -e "$bar Remove files ..."
rm -v /root/gpio*.py
rm -v /srv/http/gpio*.php
path=/srv/http/assets
rm -v $path/css/gpiosettings.css
rm -v $path/img/RPi3_GPIOs.png
rm -v $path/js/gpio*
rm -v $path/js/vendor/bootstrap-select-1.12.1.min.js

# restore modified files #######################################
echo -e "$bar Restore modified files ..."
header=/srv/http/app/templates/header.php
echo $header
sed -i -e '\|<?php // gpio|, /?>/ d
' -e '/id="ond"/, /id="offd"/ d
' -e '/id="gpio"/ d
' -e '/id="gpiosettings"/ d
' $header

footer=/srv/http/app/templates/footer.php
echo $footer
sed -i -e 's/id="poweroff"/id="syscmd-poweroff"/
' -e 's/id="reboot"/id="syscmd-reboot"/
' -e '/gpio.js/ d
' $footer

# if RuneUI enhancement not installed
if [[ ! -e /usr/local/bin/uninstall_enha.sh ]]; then
	rm $path/css/pnotify.css
	rm $path/js/vendor/pnotify3.custom.min.js
	sed -i '/pnotify.css/ d' $header
	sed -i '/pnotify3.custom.min.js/ d' $footer
fi

sed -i '\|/\* gpio \*/| d' /srv/http/assets/css/runeui.css

# Dual boot
sed -i -e '/^#"echo/ s/^#//g
' -e '/gpiopower.py/d
' /root/.xbindkeysrc

if [[ $1 != u ]]; then
	cp -vf /etc/mpd.conf{.pacorig,}
	systemctl restart mpd
fi

udev=/etc/udev/rules.d/rune_usb-audio.rules
echo $udev
sed -i '/SUBSYSTEM=="sound"/ s/^#//' $udev
udevadm control --reload

echo -e "$bar Remove service ..."
systemctl disable gpioset
systemctl daemon-reload
rm -v /etc/systemd/system/gpioset.service

uninstallfinish $@
