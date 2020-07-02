#!/bin/bash

file=/srv/http/data/tmp/gpiotimer
timer=$( cat $file )

i=$timer

looptimer() {
	[[ ! -e $file ]] && exit
	
	sleep 60	
	[[ ! -e $file ]] && exit
	
	if [[ $( cat /proc/asound/card*/pcm*/sub*/status | grep -q state ) == 0 ]]; then # state: RUNNING
		[[ $i != $timer ]] && echo $timer > $file
	else
		i=$( cat $file )
		(( i-- ))
		if (( $i == 1 )); then
			curl -s -X POST "http://127.0.0.1/pub?id=gpio" -d '{ "state": "IDLE", "delay": 60 }'
		elif (( $i == 0 )); then
			gpiooff.py
			exit
			
		fi
		echo $i > $file
	fi
	looptimer
}
looptimer
