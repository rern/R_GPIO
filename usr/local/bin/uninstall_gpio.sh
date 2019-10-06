#!/bin/bash

alias=gpio

. /srv/http/addonsfunctions.sh
. /srv/http/addonsedit.sh

# gpio off #######################################
./gpiooff.py &> /dev/null &

uninstallstart $@

echo -e "$bar Remove files ..."
rm -v /root/gpio*
rm -v /srv/http/gpio*
rm -v /srv/http/assets/css/gpio*
rm -v /srv/http/assets/img/RPi3_GPIO*
rm -v /srv/http/assets/js/gpio*

echo -e "$bar Restore files ..."
restorefile /srv/http/index.php

uninstallfinish $@

restartlocalbrowser
