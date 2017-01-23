#!/usr/bin/python
import json
import time
import os
import mpd
import requests

with open('/root/gpio.json') as jsonfile:
	gpio = json.load(jsonfile)

timer = int(gpio['timer']['timer'])

if timer == 0:
	exit()

i = timer
while i >= 0:
	time.sleep(60)
	client = mpd.MPDClient(use_unicode=True)
	client.connect("localhost", 6600)
	state = client.status()['state']
	client.close()
	client.disconnect()
	if state == "play":
		i = timer
	else:
		i -= 1
		if i == 1: # broadcast last loop
			txt = str(60) +"IDLE"
			requests.post("http://localhost/pub?id=gpio", json=txt)
		if i == 0:
			os.system("/usr/bin/php /srv/http/gpiooff.php")
