#!/usr/bin/python
import redis
import json
import os

r = redis.Redis('localhost')
r.set('gpio', 
	'{\"enable\":{\"enable\":0},' \
	'\"pin\":{\"pin1\":31,\"pin2\":33,\"pin3\":35,\"pin4\":37},' \
	'\"name\":{\"name1\":\"DAC\",\"name2\":\"Preamp\",\"name3\":\"Amp\",\"name4\":\"Subwoofer\"},' \
	'\"on\":{\"on1\":31,\"ond1\":2,\"on2\":33,\"ond2\":2,\"on3\":35,\"ond3\":2,\"on4\":37},' \
	'\"off\":{\"off1\":37,\"offd1\":2,\"off2\":35,\"offd2\":2,\"off3\":33,\"offd3\":2,\"off4\":31},' \
	'\"timer\":{\"timer\":5}}')
