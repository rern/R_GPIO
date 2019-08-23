#!/bin/bash

alias=gpio

. /srv/http/addonstitle.sh

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

echo -e "$bar Remove service ..."
systemctl disable gpioset
rm -v /etc/systemd/system/gpioset.service
systemctl daemon-reload

uninstallfinish $@

restartlocalbrowser
