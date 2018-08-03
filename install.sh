#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh
. /srv/http/addonsedit.sh

installstart $@

ln -sf /usr/bin/python{2.7,}

# install RuneUI GPIO #######################################
mv /srv/http/gpio.json{,.backup} &> /dev/null

getinstallzip

mv /srv/http/gpio.json{.backup,} &> /dev/null

# modify files #######################################
echo -e "$bar Modify files ..."

[[ -e /usr/local/bin/uninstall_enha.sh ]] && enha=1

file=/srv/http/app/templates/header.php
echo $file

string=$( cat <<'EOF'
	<link rel="stylesheet" href="<?=$this->asset('/css/gpio.css')?>">
EOF
)
appendH 'runeui.css'
if [[ enha ]]; then
	file=$file.backup
	appendH 'runeui.css'
	file=${file/.backup/}
fi

string=$( cat <<'EOF'
    <li><a id="gpio"><i class="fa"></i>GPIO</a></li>
EOF
)
appendH 'poweroff-modal'
if [[ enha ]]; then
	file=$file.backup
	appendH 'poweroff-modal'
fi

file=/srv/http/app/templates/footer.php
echo $file

string=$( cat <<'EOF'
<script src="<?=$this->asset('/js/gpio.js')?>"></script>
EOF
)
appendH '$'
[[ enha ]] && file=$file.backup; appendH '$'

# Dual boot
if [[ -e /usr/local/bin/hardreset ]]; then
    file=/root/.xbindkeysrc
    echo $file

    commentS 'echo'

    string=$( cat <<'EOF'
"/root/gpiopower.py 6"
EOF
)
    appendS 'echo 6'

    string=$( cat <<'EOF'
"/root/gpiopower.py 8"
EOF
)
    appendS 'echo 8'
fi

# set initial gpio #######################################
echo -e "$bar GPIO service ..."

echo '[Unit]
Description=GPIO initial setup
[Service]
Type=idle
ExecStart=/usr/bin/python /root/gpio.py set
[Install]
WantedBy=multi-user.target
' > /etc/systemd/system/gpioset.service

systemctl enable gpioset
systemctl daemon-reload
/root/gpio.py set

# set permission #######################################
echo 'http ALL=NOPASSWD: ALL' > /etc/sudoers.d/http
chmod 4755 /usr/bin/sudo
usermod -a -G root http # add user osmc to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpio.py set for every boot

installfinish $@

clearcache

title -nt "$info Menu > GPIO: long-press = setting, tap = on/off"
