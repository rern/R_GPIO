#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh

# gpio off #######################################
./gpiooff.py &>/dev/null &

uninstallstart $1

# remove files #######################################
echo -e "$bar Remove files ..."
rm -v /root/{gpiooff.py,gpioon.py,gpiotimer.py,poweroff.py,reboot.py}
rm -v /srv/http/{gpioo*,gpios*,gpiot*}
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
' -e '/id="gpiosettings"/ d
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

uninstallfinish $1
