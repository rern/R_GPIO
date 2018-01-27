#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh

# gpio off #######################################
./gpiooff.py &> /dev/null &

if [[ $1 != u ]]; then
	redis-cli del enablegpio aogpio volumegpio acardsgpio mpdconfgpio &> /dev/null
fi

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
' -e '/gpio.css/ d
' -e '/id="gpio"/ d
' -e '/id="gpiosettings"/ d
' $header

footer=/srv/http/app/templates/footer.php
echo $footer
sed -i -e 's/id="poweroff"/id="syscmd-poweroff"/
' -e 's/id="reboot"/id="syscmd-reboot"/
' -e '/gpio.js/ d
' $footer

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
