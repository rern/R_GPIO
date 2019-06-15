#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

installstart $@

ln -sf /usr/bin/python{2.7,}

mv /srv/http/gpio.json{,.backup} &> /dev/null

getinstallzip

mv /srv/http/gpio.json{.backup,} &> /dev/null

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

# set color
color=$( redis-cli hget display color )
[[ -n $color && $color != '#0095d8' ]] && sed -i "s|#......\(/\*c\*/\)|$color\1|g" $( grep -ril "\/\*c\*\/" /srv/http/assets/{css,js} )

installfinish $@

title -nt "$info Menu > GPIO: long-press = setting, tap = on/off"

restartlocalbrowser
