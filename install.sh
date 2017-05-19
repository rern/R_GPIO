#!/bin/bash

# install.sh - RuneUI GPIO
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

rm install.sh

linered='\e[0;31m---------------------------------------------------------\e[m'
line2='\e[0;36m=========================================================\e[m'
line='\e[0;36m---------------------------------------------------------\e[m'
bar=$( echo -e "$(tput setab 6)   $(tput setab 0)" )
warn=$( echo $(tput setab 1) ! $(tput setab 0) )
info=$( echo $(tput setab 6; tput setaf 0) i $(tput setab 0; tput setaf 7) )
runegpio=$( echo $(tput setaf 6)RuneUI GPIO$(tput setaf 7) )

# functions #######################################
title2() {
	echo -e "\n$line2\n"
	echo -e "$bar $1"
	echo -e "\n$line2\n"
}
title() {
	echo -e "\n$line"
	echo $1
	echo -e "$line\n"
}
titleend() {
	echo -e "\n$1"
	echo -e "\n$line\n"
}
error() {
	echo -e "\n$linered"
	echo $warn $1
	echo -e "$linered\n"
}
errorend() {
	echo -e "\n$warn $1"
	echo -e "\n$linered\n"
}

# check already installed #######################################
if [[ -e /srv/http/assets/css/gpiosettings.css ]]; then
	title "$info $runegpio already installed."
	echo 'Reinstall' $runegpio':'
	echo -e '  \e[0;36m0\e[m No'
	echo -e '  \e[0;36m1\e[m Yes'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 answer
	case $answer in
		1 ) ./gpiouninstall.sh re;;
		* ) echo
			titleend "$runegpio reinstall cancelled."
			exit;;
	esac
fi

# install packages #######################################
title2 "Install $runegpio ..."

[[ ! -e /usr/bin/python ]] && ln -s /usr/bin/python2.7 /usr/bin/python

if ! pacman -Q python2-pip > /dev/null 2>&1 && ! pacman -Q python-pip > /dev/null 2>&1; then
	if [[ ! -e /var/cache/pacman/pkg/python2-pip-9.0.1-2-any.pkg.tar.xz ]]; then
		title "Get packages file ..."
		wget -q --show-progress -O var.tar "https://github.com/rern/RuneUI_GPIO/blob/master/_repo/var.tar?raw=1"
		tar -xvf var.tar -C /
		rm var.tar
	fi
	title "Install Pip ..."
	pacman -S --noconfirm python2-pip
	ln -s /usr/bin/pip2 /usr/bin/pip
fi

if ! python -c "import mpd" > /dev/null 2>&1; then
	if [[ ! -e /var/cache/pacman/pkg/python-mpd2-0.5.5.tar.gz ]] || [[ ! -e /var/cache/pacman/pkg/requests-2.12.5-py2.py3-none-any.whl ]]; then
		title "Get Pip packages file ..."
		wget -q --show-progress -O varpip.tar "https://github.com/rern/RuneUI_GPIO/blob/master/_repo/varpip.tar?raw=1"
		tar -xvf varpip.tar -C /
		rm varpip.tar
	fi
	title "Install Python-MPD ..."
	pip install /var/cache/pacman/pkg/python-mpd2-0.5.5.tar.gz
fi
if ! python -c "import requests" > /dev/null 2>&1; then
	title "Install Python-Request ..."
	pip install /var/cache/pacman/pkg/requests-2.12.5-py2.py3-none-any.whl
fi

# get DAC config #######################################
if [[ -f /etc/mpd.conf.gpio ]]; then
	title "$info DAC configuration from previous install found."
	echo 'Discard:'
	echo -e '  \e[0;36m0\e[m Discard (new DAC)'
	echo -e '  \e[0;36m1\e[m Keep   (same DAC)'
	echo
	echo -e '\e[0;36m0\e[m / 1 ? '
	read -n 1 answer
	case $answer in
		1 ) echo;;
		* ) echo
			rm -v '/etc/mpd.conf.gpio';;
	esac
fi
if [[ ! -f /etc/mpd.conf.gpio ]]; then
	title "$info Get DAC configuration ready:"
	echo 'For external power DAC > power on'
	echo
	echo 'Menu > MPD > setup and verify DAC works properly before continue.'
	echo '(This install can be left running while setup.)'
	echo
	read -n 1 -s -p 'Press any key to continue ... '
	echo
fi

# install RuneUI GPIO #######################################
title "Get files ..."

wget -q --show-progress -O RuneUI_GPIO.tar.xz "https://github.com/rern/RuneUI_GPIO/blob/master/_repo/RuneUI_GPIO.tar.xz?raw=1"
wget -q --show-progress -O uninstall_gpio.sh "https://github.com/rern/RuneUI_GPIO/blob/master/uninstall_gpio.sh?raw=1"
chmod 755 uninstall_gpio.sh

# extract files #######################################
title "Install new files ..."
bsdtar -xvf RuneUI_GPIO.tar.xz -C / $([ -f /srv/http/gpio.json ] && echo '--exclude=gpio.json')
rm RuneUI_GPIO.tar.xz

chmod -R 755 /etc/sudoers.d
chmod 755 /root/*.py
chmod 755 /srv/http/*.php

# modify files #######################################
title "Modify files ..."
udev='/etc/udev/rules.d/rune_usb-audio.rules'
echo $udev
sed -i '/SUBSYSTEM=="sound"/ s/^/#/' $udev
udevadm control --reload

header='/srv/http/app/templates/header.php'
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
            <li><a href="gpiosettings.php"><i class="fa fa-volume-off"></i> GPIO</a></li>
' -e '/class="home"/ a\
    <button id="gpio" class="btn btn-default btn-cmd"><i class="fa fa-volume-off fa-lg"></i></button>
' $header
# no RuneUI enhancement
! grep -q 'pnotify.css' $header &&
	sed -i $'/runeui.css/ a\    <link rel="stylesheet" href="<?=$this->asset(\'/css/pnotify.css\')?>">' $header

footer='/srv/http/app/templates/footer.php'
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
	cp -rfv /etc/mpd.conf /etc/mpd.conf.gpio

title "GPIO service ..."
systemctl enable gpioset
systemctl daemon-reload
systemctl start gpioset

# refresh #######################################
title "Clear PHP OPcache ..."
curl '127.0.0.1/clear'
echo

if pgrep midori > /dev/null; then
	killall midori
	sleep 1
	xinit > /dev/null 2>&1 &
	echo -e '\nLocal browser restarted.\n'
fi

title2 "$runegpio successfully installed."
echo "Uninstall:   ./uninstall_gpio.sh"
titleend "$info Refresh browser and go to Menu > GPIO for settings."
