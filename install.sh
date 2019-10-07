#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonsfunctions.sh

installstart $@

if [[ -e /usr/bin/python2.7 ]]; then
	title "$bar Upgrade python ... "
	pacman -Rcns --noconfirm python2 python2-pip python python-pip
	rm -f /usr/bin/{pip,python}
	rm -r /usr/lib/python*

	pacman -Sy --noconfirm python python-pip
	pip install -y RPi.GPIO
fi

getinstallzip

file=/srv/http/data/gpio/gpio.json
if [[ ! -e $file ]]; then
    cat << 'EOF' > $file
{
"name":{"11":"DAC","13":"PreAmp","15":"Amp","16":"Subwoofer"},
"on":{"on1":11,"ond1":2,"on2":13,"ond2":2,"on3":15,"ond3":2,"on4":16},
"off":{"off1":16,"offd1":2,"off2":15,"offd2":2,"off3":13,"offd3":2,"off4":11},
"timer":5
}
EOF
    chown http:http $file
fi

# set permission #######################################
chmod 755 /root/gpio/*
usermod -a -G root http # add user http to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpio.py set for every boot

setColor

installfinish $@

restartlocalbrowser
