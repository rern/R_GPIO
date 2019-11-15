#!/bin/bash

alias=gpio

. /srv/http/addons-functions.sh

# gpio off #######################################
/root/gpio/gpiooff.py &> /dev/null &

uninstallstart $@

echo -e "$bar Remove files ..."
rm -rv /root/gpio
rm -v /srv/http/gpio*
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO*
rm -v /srv/http/assets/js/gpio*

uninstallfinish $@

restartlocalbrowser
