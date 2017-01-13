#!/usr/bin/python
import RPi.GPIO as GPIO
import redis
import json

r = redis.Redis('localhost')
gpio = r.get('gpio') # return string as 'b' byte literal
gpio = gpio.decode('UTF-8') # convert to utf-8
gpio = json.loads(gpio) # convert to json
pin = gpio['pin'] # get data as key['value']

pin1 = int(pin['pin1']) # convert to integer
pin2 = int(pin['pin2'])
pin3 = int(pin['pin3'])
pin4 = int(pin['pin4'])

pinx = [pin1, pin2, pin3, pin4]
pinx = [i for i in pinx if i != 0] # remove '0' from array

GPIO.setwarnings(0)
GPIO.setmode(GPIO.BOARD)
GPIO.setup(pinx, GPIO.OUT)

GPIO.output(pinx, 1)
