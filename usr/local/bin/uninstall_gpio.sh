#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

# gpio off #######################################
./gpiooff.py &> /dev/null &

uninstallstart $@

# remove files #######################################
echo -e "$bar Remove files ..."
rm -v /root/gpio*
rm -v /srv/http/gpio*
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO.svg
rm -v /srv/http/assets/js/gpio*
rm -v /srv/http/assets/js/vendor/bootstrap-select-1.12.1.min.js
[[ ! -e /srv/http/enhance.php ]] && rm -v /srv/http/assets/css/bootstrap.min.css

# restore modified files #######################################
echo -e "$bar Restore modified files ..."

[[ -e /srv/http/app/templates/header.php.backup ]] && backup=.backup
files="
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

restartlocalbrowser
