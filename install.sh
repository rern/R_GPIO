#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh

installstart $@

[[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2.7 /usr/bin/python

if ! pacman -Q python2-pip &> /dev/null && ! pacman -Q python-pip &> /dev/null; then
	rankmirrors
	
	echo -e "$bar Install Pip ..."
	pacman -S --noconfirm python2-pip
	[[ ! -e /usr/bin/pip ]] && ln -s /usr/bin/pip{2,}

	echo -e "$bar Install Python-MPD ..."
	pip -q install python-mpd2

	echo -e "$bar Install Python-Request ..."
	pip -q install requests
fi

# install RuneUI GPIO #######################################
[[ -e /srv/http/gpio.json ]] && mv /srv/http/gpio.json{,.backup}

getinstallzip

[[ -e /srv/http/gpio.json.backup ]] && mv /srv/http/gpio.json{.backup,}

# modify files #######################################
echo -e "$bar Modify files ..."
file=/etc/udev/rules.d/rune_usb-audio.rules
echo $file
sed -i '/SUBSYSTEM=="sound"/ s/^/#/' $file
udevadm control --reload

file=/srv/http/app/templates/header.php
echo $file
sed -i -e $'1 i\
<?php // gpio\
$file = \'/srv/http/gpio.json\';\
$fileopen = fopen($file, \'r\');\
$gpio = fread($fileopen, filesize($file));\
fclose($fileopen);\
$gpio = json_decode($gpio, true);\
$on = $gpio[\'on\'];\
$off = $gpio[\'off\'];\
$ond = $on[\'ond1\'] + $on[\'ond2\'] + $on[\'ond3\'];\
$offd = $off[\'offd1\'] + $off[\'offd2\'] + $off[\'offd3\'];\
?>
' -e '/id="menu-top"/ i\
<input id="ond" type="hidden" value=<?=$ond ?>>\
<input id="offd" type="hidden" value=<?=$offd ?>>
' -e '/Credits/ a\
            <li style="cursor: pointer;"><a id="gpiosettings"><i class="fa fa-volume-off" style="width: 18px; font-size: 20px;"></i> GPIO</a></li>
' -e '/class="home"/ a\
    <button id="gpio" class="btn btn-default btn-cmd"><i class="fa fa-volume-off fa-lg"></i></button>
' $file
# no RuneUI enhancement
! grep -q 'pnotify.css' $file &&
	sed -i $'/runeui.css/ a\    <link rel="stylesheet" href="<?=$this->asset(\'/css/pnotify.css\')?>">' $file

file=/srv/http/app/templates/footer.php
echo $file
sed -i -e 's/id="syscmd-poweroff"/id="poweroff"/
' -e 's/id="syscmd-reboot"/id="reboot"/
' -e $'$ a\
<script src="<?=$this->asset(\'/js/gpio.js\')?>"></script>
' $file
# no RuneUI enhancement
! grep -q 'pnotify3.custom.min.js' $file &&
echo '<script src="<?=$this->asset('"'"'/js/vendor/pnotify3.custom.min.js'"'"')?>"></script>' >> $file

#echo '.playback-controls {
#    left: 55px;
#}' >> /srv/http/assets/css/runeui.css

[[ ! -f /etc/mpd.conf.gpio ]] && cp -rfv /etc/mpd.conf{,.gpio}

# Dual boot
sed -i -e '/echo/ s/^/#/g
' -e '/echo 6/ a\
"/root/gpiopower.py 6"
' -e '/echo 8/ a\
"/root/gpiopower.py 8"
' /root/.xbindkeysrc

# set initial gpio #######################################
echo -e "$bar GPIO service ..."
systemctl daemon-reload
systemctl enable gpioset
systemctl start gpioset

# set permission #######################################
echo 'http ALL=NOPASSWD: ALL' > /etc/sudoers.d/http
[[ $(stat -c %a /usr/bin/sudo) != 4755 ]] && chmod 4755 /usr/bin/sudo
#chmod -R 550 /etc/sudoers.d
usermod -a -G root http # add user osmc to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpioset.py for every boot

installfinish $@

clearcache

title -nt "$info Menu > GPIO for settings."
