#!/bin/bash

file=/srv/http/data/tmp/gpiotimer
timer=$( cat $file )
i=$timer

while sleep 60; do
	[[ ! -e $file ]] && exit
	
	if grep -q RUNNING /proc/asound/card*/pcm*/sub*/status; then # state: RUNNING
		[[ $i != $timer ]] && echo $timer > $file
	else
		i=$( cat $file )
		(( i-- ))
		if (( $i < 6 && $i > 1 )); then
			curl -s -X POST "http://127.0.0.1/pub?id=notify" -d '{ "title": "GPIO Idle Timer", "text": "'$i' minutes to OFF", "icon": "stopwatch" }'
		elif (( $i == 1 )); then
			curl -s -X POST "http://127.0.0.1/pub?id=gpio" -d '{ "state": "IDLE", "delay": 60 }'
		elif (( $i == 0 )); then
			rm $file
			/usr/local/bin/gpiooff.py
			exit
			
		fi
		echo $i > $file
	fi
done
