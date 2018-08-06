#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

# gpio off #######################################
./gpiooff.py &> /dev/null &

uninstallstart $@

# remove files #######################################
echo -e "$bar Remove files ..."
rm -v /root/gpio*.py
rm -v /srv/http/gpio*.php
rm -v /srv/http/app/templates/gpio*
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO.svg
rm -v /srv/http/assets/js/gpio*
rm -v /srv/http/assets/js/vendor/bootstrap-select-1.12.1.min.js

# restore modified files #######################################
echo -e "$bar Restore modified files ..."

if [[ -e /srv/http/app/templates/header.php.backup ]]; then
backup=.backup
file=/srv/http/app/templates/header.php
commentH 'gpio'
file=/srv/http/app/templates/footer.php
commentH 'gpio'
fi
files="
/srv/http/index.php
/srv/http/app/templates/header.php$backup
/srv/http/app/templates/footer.php$backup
/root/.xbindkeysrc
"
restorefile $files

echo -e "$bar Remove service ..."
systemctl disable gpioset
systemctl daemon-reload
rm -v /etc/systemd/system/gpioset.service

uninstallfinish $@
