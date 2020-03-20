#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

[[ -e /srv/http/addons-functions.sh ]] && . /srv/http/addons-functions.sh || . /srv/http/bash/addons-functions.sh

installstart $@

if ! pip list | grep RPi.GPIO &> /dev/null; then
	yes 2> /dev/null | pip --no-cache-dir install RPi.GPIO
fi

getinstallzip

file=/srv/http/data/gpio/gpio.json
if [[ ! -e $file ]]; then
    cat << 'EOF' > $file
{
	"name"  : { "11":"DAC", "13":"PreAmp", "15":"Amp", "16":"Subwoofer" },
	"on"    : { "on1": 11, "ond1": 2, "on2": 13, "ond2": 2, "on3": 15, "ond3": 2, "on4": 16 },
	"off"   : { "off1":16, "offd1":2, "off2":15, "offd2":2, "off3":13, "offd3":2, "off4":11 },
	"timer" : 5
}
EOF
    chown http:http $file
fi

# set permission #######################################
chmod 755 /usr/local/bin/gpio*
usermod -a -G root http # add user http to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpio.py set for every boot

[[ -e /srv/http/data/display/color ]] && /srv/http/bash/setcolor.sh

installfinish $@

restartlocalbrowser
