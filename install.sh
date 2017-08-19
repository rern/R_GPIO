#!/bin/bash

# install.sh [any = skip DAC ready prompt]

# https://github.com/rern/RuneUI_GPIO

# remove install.sh
# already installed
#	reinstall ?
#		exit
#		uninstall
# install
#	Pip
#	python packages
#	get gpiouninstall.sh
#	get tar.xz
#	modify files
#	extract
#	remove tar.xz
#	set gpio default
# 	enable gpioset service
#	reload sudoers
# success
#	clear opcache
#	restart local browser
#	info

rm $0

# import heading function
wget -qN https://raw.githubusercontent.com/rern/title_script/master/title.sh; . title.sh; rm title.sh
timestart

runegpio=$( tcolor "RuneUI GPIO" )

# check already installed #######################################
if [[ -e /srv/http/assets/css/gpiosettings.css ]]; then
	echo -e "$info $runegpio already installed."
	yesno "Reinstall $runegpio:" answer
	[[ $answer != 1 ]] && exit
	./uninstall_gpio.sh re
fi

# user inputs
# get DAC config #######################################
# skip with any argument
if (( $# == 0 )); then
	if [[ -f /etc/mpd.conf.gpio ]]; then
		echo -e "$info DAC configuration from previous install found."
		yesno "Ignore:" ansconf
		[[ $ansconf == 1 ]] && rm -v /etc/mpd.conf.gpio
	fi
	if [[ ! -f /etc/mpd.conf.gpio ]]; then
		echo -e "$info Get DAC configuration ready:"
		echo 'For external power DAC > power on'
		echo
		echo 'Menu > MPD > setup and verify DAC works properly before continue.'
		echo '(This install can be left running while setup.)'
		echo
		read -n 1 -s -p 'Press any key to continue ... '
		echo
	fi
fi

gitpath=https://raw.githubusercontent.com/rern/RuneUI_GPIO/master
pkgpath=/var/cache/pacman/pkg

# install packages #######################################
title -l = "$bar Install $runegpio ..."

[[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2.7 /usr/bin/python

if ! pacman -Q python2-pip &>/dev/null && ! pacman -Q python-pip &>/dev/null; then
	if [[ ! -e $pkgpath/python2-pip-9.0.1-2-any.pkg.tar.xz ]]; then
		echo -e "$bar Get packages file ..."
		wget -qN --show-progress $gitpath/_repo/var.tar
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

	ln -s /usr/bin/pip{2,}
fi

if ! python -c "import mpd" &>/dev/null; then
	if [[ ! -e $pkgpath/python-mpd2-0.5.5.tar.gz ]] || [[ ! -e $pkgpath/requests-2.12.5-py2.py3-none-any.whl ]]; then
		echo -e "$bar Get Pip packages file ..."
		wget -qN --show-progress $gitpath/_repo/varpip.tar
		tar -xvf varpip.tar -C /
		rm varpip.tar
	fi
	echo -e "$bar Install Python-MPD ..."
	pip install $pkgpath/python-mpd2-0.5.5.tar.gz
fi
if ! python -c "import requests" &>/dev/null; then
	echo -e "$bar Install Python-Request ..."
	pip install $pkgpath/requests-2.12.5-py2.py3-none-any.whl
fi

# install RuneUI GPIO #######################################
echo -e "$bar Get files ..."

wget -qN --show-progress $gitpath/_repo/RuneUI_GPIO.tar.xz
wget -qN --show-progress $gitpath/uninstall_gpio.sh
chmod 755 uninstall_gpio.sh

# extract files #######################################
echo -e "$bar Install new files ..."
bsdtar -xvf RuneUI_GPIO.tar.xz -C / $([ -f /srv/http/gpio.json ] && echo '--exclude gpio.json')
rm RuneUI_GPIO.tar.xz
chmod 755 /etc/sudoers.d/sudoers /root/*.py

# modify files #######################################
echo -e "$bar Modify files ..."
udev=/etc/udev/rules.d/rune_usb-audio.rules
echo $udev
sed -i '/SUBSYSTEM=="sound"/ s/^/#/' $udev
udevadm control --reload

header=/srv/http/app/templates/header.php
echo $header
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
            <li><a href="/gpiosettings.php"><i class="fa fa-volume-off"></i> GPIO</a></li>
' -e '/class="home"/ a\
    <button id="gpio" class="btn btn-default btn-cmd"><i class="fa fa-volume-off fa-lg"></i></button>
' $header
# no RuneUI enhancement
! grep -q 'pnotify.css' $header &&
	sed -i $'/runeui.css/ a\    <link rel="stylesheet" href="<?=$this->asset(\'/css/pnotify.css\')?>">' $header

footer=/srv/http/app/templates/footer.php
echo $footer
sed -i -e 's/id="syscmd-poweroff"/id="poweroff"/
' -e 's/id="syscmd-reboot"/id="reboot"/
' -e $'$ a\
<script src="<?=$this->asset(\'/js/gpio.js\')?>"></script>
' $footer
# no RuneUI enhancement
! grep -q 'pnotify3.custom.min.js' $footer &&
	sed -i $'$ a\
	<script src="<?=$this->asset(\'/js/vendor/pnotify3.custom.min.js\')?>"></script>
	' $footer

[[ ! -f /etc/mpd.conf.gpio ]] &&
	cp -rfv /etc/mpd.conf{,.gpio}

# Dual boot
sed -i -e '/echo/ s/^/#/g
' -e '/echo 6/ a\
"/root/reboot.py 6"
' -e '/echo 8/ a\
"/root/reboot.py 8"
' /root/.xbindkeysrc
killall xbindkeysrc
export DISPLAY=":0" &
xbindkeysrc &

# set initial gpio #######################################
echo -e "$bar GPIO service ..."
systemctl daemon-reload
systemctl enable gpioset
systemctl start gpioset

# set permission #######################################
sed -i 's/#includedir/includedir/' /etc/sudoers
echo 'http ALL=NOPASSWD: ALL' > /etc/sudoers.d/sudoers
usermod -a -G root http # add user osmc to group root to allow /dev/gpiomem access
#chmod g+rw /dev/gpiomem # allow group to access set in gpioset.py for every boot

# refresh #######################################
echo -e "$bar Clear PHP OPcache ..."
curl '127.0.0.1/clear'
echo

if pgrep midori >/dev/null; then
	killall midori
	sleep 1
	xinit &>/dev/null &
	echo 'Local browser restarted.'
fi

timestop
title -l = "$bar $runegpio successfully installed."
echo 'Uninstall: ./uninstall_gpio.sh'
title -nt "$info Refresh browser and go to Menu > GPIO for settings."
