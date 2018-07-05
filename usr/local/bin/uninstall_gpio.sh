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
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO.svg
rm -v /srv/http/assets/js/gpio*
rm -v /srv/http/assets/js/vendor/bootstrap-select-1.12.1.min.js

# restore modified files #######################################
echo -e "$bar Restore modified files ..."

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

# Dual boot
sed -i -e '/^#"echo/ s/^#//g
' -e '/gpiopower.py/d
' /root/.xbindkeysrc

echo -e "$bar Remove service ..."
systemctl disable gpioset
systemctl daemon-reload
rm -v /etc/systemd/system/gpioset.service

uninstallfinish $@
