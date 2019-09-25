#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonsfunctions.sh
. /srv/http/addonsedit.sh

installstart $@

ln -sf /usr/bin/python{2.7,}

getinstallzip

file=/srv/http/index.php
echo $file
string=$( cat <<'EOF'
<script src="/assets/js/gpio.<?=$time?>.js"></script>
EOF
)
appendH 'js/lyrics'

file=/srv/http/indexbody.php
echo $file
string=$( cat <<'EOF'
	<a id="gpio"><i class="fa fa-gpio"></i>GPIO<i class="fa fa-gear submenu"></i></a>
EOF
)
appendH 'fa-power'

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

file="$( ls -d /mnt/MPD/USB/*/ ).mpdignore"
! grep -q gpio "$file" && echo gpio >> "$file"

# set permission #######################################
chmod 755 /root/gpio*
usermod -a -G root http # add user http to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpio.py set for every boot

setColor

installfinish $@

restartlocalbrowser
