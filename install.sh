#!/bin/bash

# change version number in RuneAudio_Addons/srv/http/addonslist.php

alias=gpio

. /srv/http/addonstitle.sh

installstart $1

gitpath=https://github.com/rern/_assets/raw/master/RuneUI_GPIO
pkgpath=/var/cache/pacman/pkg

[[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2.7 /usr/bin/python

if ! pacman -Q python2-pip &> /dev/null && ! pacman -Q python-pip &> /dev/null; then
	if [[ ! -e $pkgpath/python2-pip-9.0.1-2-any.pkg.tar.xz ]]; then
		echo -e "$bar Get packages file ..."
		wgetnc $gitpath/var.tar
		tar -xvf var.tar -C /
		rm var.tar
	fi
	echo -e "$bar Install Pip ..."
	pacman -U --noconfirm \
		$pkgpath/python2-appdirs-1.4.0-5-any.pkg.tar.xz \
		$pkgpath/python2-pyparsing-2.1.10-2-any.pkg.tar.xz \
		$pkgpath/python2-six-1.10.0-3-any.pkg.tar.xz \
		$pkgpath/python2-packaging-16.8-2-any.pkg.tar.xz \
		$pkgpath/python2-setuptools-1_34.0.1-1-any.pkg.tar.xz \
		$pkgpath/python2-pip-9.0.1-2-any.pkg.tar.xz

	[[ -e /usr/bin/pip ]] && ln -s /usr/bin/pip{2,}
fi

if ! python -c "import mpd" &> /dev/null; then
	if [[ ! -e $pkgpath/python-mpd2-0.5.5.tar.gz ]] || [[ ! -e $pkgpath/requests-2.12.5-py2.py3-none-any.whl ]]; then
		echo -e "$bar Get Pip packages file ..."
		wgetnc $gitpath/varpip.tar
		tar -xvf varpip.tar -C /
		rm varpip.tar
	fi
	echo -e "$bar Install Python-MPD ..."
	pip install $pkgpath/python-mpd2-0.5.5.tar.gz
fi
if ! python -c "import requests" &> /dev/null; then
	echo -e "$bar Install Python-Request ..."
	pip install $pkgpath/requests-2.12.5-py2.py3-none-any.whl
fi

# install RuneUI GPIO #######################################
echo -e "$bar Get files ..."
wgetnc https://github.com/rern/RuneUI_GPIO/archive/master.zip

echo -e "$bar Install new files ..."
rm -rf /tmp/install
mkdir -p /tmp/install
bsdtar --exclude='.*' --exclude='*.md' -xvf master.zip --strip 1 -C /tmp/install
rm master.zip /tmp/install/* &> /dev/null
[[ -e /srv/http/gpio.json ]] && rm /tmp/install/srv/http/gpio.json
if [[ -L /root ]]; then # fix 0.4b /root as symlink
	mkdir /tmp/install/home
	mv /tmp/install/{,home/}root
fi

chown -R root:root /tmp/install
chown -R http:http /tmp/install/srv/http
chmod -R 755 /tmp/install
chmod -R 644 /tmp/install/etc/systemd/system

cp -rfp /tmp/install/* /
rm -rf /tmp/install

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
' -e '/poweroff-modal/ i\
            <li style="cursor: pointer;">\
				<a id="gpiosettings"><i class="fa fa-volume-off" style="width: 18px; font-size: 20px;"></i> GPIO</a>\
			</li>
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

[[ ! -f /etc/mpd.conf.gpio ]] && cp -rfv /etc/mpd.conf{,.gpio}

# Dual boot
sed -i -e '/echo/ s/^/#/g
' -e '/echo 6/ a\
"/root/reboot.py 6"
' -e '/echo 8/ a\
"/root/reboot.py 8"
' /root/.xbindkeysrc
killall xbindkeys
export DISPLAY=":0" &
xbindkeys &

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

installfinish $1

clearcache

title -nt "$info Menu > GPIO for settings."
