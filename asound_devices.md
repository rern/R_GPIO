```sh
### for name    "bcm2835 ALSA_N"
### for device  "hw:0,N"

cat /proc/asound/pcm

# 00-00: bcm2835 ALSA : bcm2835 ALSA : playback 8
# 00-01: bcm2835 ALSA : bcm2835 IEC958/HDMI : playback 1


cat /proc/asound/cards
# 0 [ALSA           ]: bcm2835 - bcm2835 ALSA
#                      bcm2835 ALSA

cat /proc/asound/devices
#  0: [ 0]   : control
# 16: [ 0- 0]: digital audio playback
# 17: [ 0- 1]: digital audio playback
# 33:        : timer

cat /proc/asound/modules
# 0 snd_bcm2835
```
