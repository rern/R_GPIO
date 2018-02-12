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

file=/etc/udev/rules.d/rune_usb-audio.rules
echo $file
sed -i '/SUBSYSTEM=="sound"/ s/^#//
' -e '/^ACTION/ d
' $file

udevadm control --reload-rules && udevadm trigger

file=/srv/http/app/templates/header.php
echo $file
sed -i -e '\|<?php // gpio|, /?>/ d
' -e '/gpio.css\|id="enable"\|id="gpio"\|gpiosettings.php/ d
' $file

file=/srv/http/app/templates/footer.php
echo $footer
sed -i -e 's/id="poweroff"/id="syscmd-poweroff"/
' -e 's/id="reboot"/id="syscmd-reboot"/
' -e '/gpio.js/ d
' $file

file=/srv/http/command/refresh_ao
echo $file
sed -i '/udac0/,/udac1/ d' $file

# Dual boot
sed -i -e '/^#"echo/ s/^#//g
' -e '/gpiopower.py/d
' /root/.xbindkeysrc

echo -e "$bar Remove service ..."
systemctl disable gpioset
systemctl daemon-reload
rm -v /etc/systemd/system/gpioset.service

uninstallfinish $@
