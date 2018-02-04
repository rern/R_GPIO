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
file=/etc/mpd.conf
echo $file
chmod 666 $file

file=/etc/udev/rules.d/rune_usb-audio.rules
echo $file
sed -i '/SUBSYSTEM=="sound"/ s/^/#/' $file
udevadm control --reload

file=/srv/http/app/templates/header.php
echo $file
sed -i -e $'1 i\
<?php // gpio\
$redis = new Redis();\
$redis->pconnect( \'127.0.0.1\' );\
$enable = $redis->get( \'enablegpio\' );\
\
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

file=/srv/http/app/templates/mpd.php
echo $file
sed -i -e '/This switches output/{n;n;n;n; i\
            <div class="form-group"> <?php /* gpio0 */?>\
                <label class="col-sm-2 control-label" for="audio-output-interface">RuneUI GPIO</label>\
                <div class="col-sm-10">\
                    <a class="btn btn-primary btn-lg" id="dacsave">Save</a>\
                    <span class="help-block">Configure the rest of this page and save for <strong>RuneUI GPIO</strong> reloading when power on.</span>\
                </div>\
            </div> <?php /* gpio1 */?>
}
' -e 's/id="log-level"\( name="conf\[user\]"\)/id="user"\1/
' -e 's/id="log-level"\( name="conf\[state_file\]"\)/id="state"\1/
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

ao=$( redis-cli get ao )
redis-cli set aogpio $ao &> /dev/null

# set initial gpio #######################################
echo -e "$bar GPIO service ..."
systemctl daemon-reload
systemctl enable gpioset
systemctl start gpioset

# set permission #######################################
echo 'http ALL=NOPASSWD: ALL' > /etc/sudoers.d/http
chmod 4755 /usr/bin/sudo
usermod -a -G root http # add user osmc to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpioset.py for every boot

installfinish $@

clearcache

echo -e "$info Menu > GPIO for settings."
title -nt "$info USB DAC not listed: power on > reboot"

# refresh svg support last for webui installation
[[ $svg == 0 ]] && systemctl reload nginx
