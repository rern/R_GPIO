#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

installstart $@

ln -sf /usr/bin/python{2.7,}

getinstallzip

makeDirLink gpio

file=/srv/http/assets/img/gpio/gpio.json
if [[ ! -e $( ls -A $file ) ]]; then
    echo '{"name":{"11":"DAC","13":"PreAmp","15":"Amp","16":"Subwoofer"},
"on":{"on1":11,"ond1":2,"on2":13,"ond2":2,"on3":15,"ond3":2,"on4":16},
"off":{"off1":16,"offd1":2,"off2":15,"offd2":2,"off3":13,"offd3":2,"off4":11},
"timer":5}' > $file
fi

# modify files #######################################
echo -e "$bar Modify files ..."

#----------------------------------------------------------------------------------
file=/srv/http/app/templates/header.php
echo $file

[[ -e $file.backup ]] && file=$file.backup

appendAsset 'runeui.css' 'gpio.css'

string=$( cat <<'EOF'
    <li><a id="gpio"><i class="fa fa-gpio"></i>GPIO</a></li>
EOF
)
appendH 'poweroff-modal'
#----------------------------------------------------------------------------------
file=/srv/http/app/templates/footer.php
echo $file

[[ -e $file.backup ]] && file=$file.backup

appendAsset 'fastclick.min.js' 'gpio.js'
#----------------------------------------------------------------------------------
# Dual boot
if [[ -e /usr/local/bin/hardreset ]]; then
    file=/root/.xbindkeysrc
    echo $file

    commentS 'echo'

    string=$( cat <<'EOF'
"/root/gpiooff.py; echo 6 > /sys/module/bcm2709/parameters/reboot_part; /var/www/command/rune_shutdown; reboot"
EOF
)
    appendS 'echo 6'

    string=$( cat <<'EOF'
"/root/gpiooff.py; echo 8 > /sys/module/bcm2709/parameters/reboot_part; /var/www/command/rune_shutdown; reboot"
EOF
)
    appendS 'echo 8'
fi

# set initial gpio #######################################
file=/etc/systemd/system/gpioset.service
echo $file

cat << 'EOF' > $file
[Unit]
Description=GPIO initial setup
[Service]
Type=idle
ExecStart=/usr/bin/python /root/gpio.py set
[Install]
WantedBy=multi-user.target
EOF

systemctl enable gpioset
systemctl daemon-reload
/root/gpio.py set

# set permission #######################################
usermod -a -G root http # add user http to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpio.py set for every boot

setColor

installfinish $@

title -nt "$info Menu > GPIO: long-press = setting, tap = on/off"

restartlocalbrowser
