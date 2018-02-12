#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh

installstart $@

ln -sf /usr/bin/python{2.7,}

rankmirrors

# remove if DAC Reloader installed
file=/usr/local/bin/uninstall_udac.sh
[[ -e $file ]] && $file u

echo -e "$bar Install Pip ..."
pacman -S --noconfirm python2-pip
ln -sf /usr/bin/pip{2,}
	
echo -e "$bar Install Python-MPD ..."
pip -q install python-mpd2

echo -e "$bar Install Python-Requests ..."
pip -q install requests

# install RuneUI GPIO #######################################
mv /srv/http/gpio.json{,.backup} &> /dev/null

getinstallzip

mv /srv/http/gpio.json{.backup,} &> /dev/null

# modify files #######################################
echo -e "$bar Modify files ..."

file=/etc/udev/rules.d/rune_usb-audio.rules
echo $file
sed -i '/SUBSYSTEM=="sound"/ s/^/#/
' -e '$ \a
ACTION=="add", KERNEL=="card*", SUBSYSTEM=="sound", RUN+="/var/www/command/refresh_ao on"\
ACTION=="remove", KERNEL=="card*", SUBSYSTEM=="sound", RUN+="/var/www/command/refresh_ao"
' $file

udevadm control --reload-rules && udevadm trigger

file=/srv/http/app/templates/header.php
echo $file
sed -i -e '1 i\
<?php // gpio\
$file = "/srv/http/gpio.json";\
$fileopen = fopen( $file, "r" );\
$gpio = fread( $fileopen, filesize( $file ) );\
fclose( $fileopen );\
\
$gpio = json_decode( $gpio, true );\
$enable = $gpio[ "enable" ];\
$on = $gpio[ "on" ];\
$off = $gpio[ "off" ];\
$ond = $on[ "ond1" ] + $on[ "ond2" ] + $on[ "ond3" ];\
$offd = $off[ "offd1" ] + $off[ "offd2" ] + $off[ "offd3" ];\
?>
' -e $'/runeui.css/ a\
	<link rel="stylesheet" href="<?=$this->asset(\'/css/gpio.css\')?>">
' -e '/id="menu-top"/ i\
<input id="enable" type="hidden" value=<?=$enable ?>>
' -e '/poweroff-modal/ i\
            <li style="cursor: pointer;"><a href="/gpiosettings.php"><i class="fa fa-volume-off" style="width: 18px; font-size: 20px;"></i> GPIO</a></li>
' -e '/class="home"/ a\
    <button id="gpio" class="btn btn-default btn-cmd"><i class="fa fa-volume-off fa-lg"></i></button>
' $file

file=/srv/http/app/templates/footer.php
echo $file
sed -i -e 's/id="syscmd-poweroff"/id="poweroff"/
' -e 's/id="syscmd-reboot"/id="reboot"/
' -e $'$ a\
<script src="<?=$this->asset(\'/js/gpio.js\')?>"></script>
' $file

file=/srv/http/command/refresh_ao
echo $file
sed -i $'/close Redis/ i\
// udac0\
if ( $argc > 1 ) {\
	// "exec" gets only last line which is new power-on card\
	$ao = exec( \'/usr/bin/aplay -lv | grep card | cut -d"]" -f1 | cut -d"[" -f2\' );\
	ui_notify( "Audio Output", "Switch to ".$ao );\
} else {\
	$ao = "bcm2835 ALSA_1";\
	ui_notify( "Audio Output", "Switch to RaspberryPi Analog Out" );\
}\
$redis->set( "ao", $ao );\
wrk_mpdconf( $redis, "switchao", $ao );\
// udac1
' $file

# for nginx svg support for gpio diagram
file=/etc/nginx/nginx.conf
if ! grep -q 'ico|svg' $file; then
	echo $file
	sed -i 's/|ico/ico|svg/' $file
	svg=0
else
	svg=1
fi

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
/root/gpio.py set

# set permission #######################################
echo 'http ALL=NOPASSWD: ALL' > /etc/sudoers.d/http
chmod 4755 /usr/bin/sudo
usermod -a -G root http # add user osmc to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpioset.py for every boot

installfinish $@

clearcache

title -nt "$info Menu > GPIO for settings."

# refresh svg support last for webui installation
[[ $svg == 0 ]] && systemctl reload nginx
