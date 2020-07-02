#!/bin/bash

alias=gpio

. /srv/http/bash/addons-functions.sh

# gpio off #######################################
gpiooff.py

uninstallstart $@

echo -e "$bar Remove files ..."
rm -rv /usr/local/bin/gpio*
rm -v /srv/http/gpio*
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO*
rm -v /srv/http/assets/js/gpio*

uninstallfinish $@

restartlocalbrowser
