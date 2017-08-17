#!/usr/bin/python
from gpio import *

data = {'enable': gpio['enable']['enable'], \
	'pullup': GPIO.input(onx[1])}

print(json.dumps(data))
