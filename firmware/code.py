# SPDX-FileCopyrightText: 2021 Kattni Rembor for Adafruit Industries
#
# SPDX-License-Identifier: MIT

"""
CircuitPython single MP3 playback example for Raspberry Pi Pico.
Plays a single MP3 once.
"""
import board
import audiomp3
import audiopwmio
import digitalio

audio = audiopwmio.PWMAudioOut(board.GP0)

decoder = audiomp3.MP3Decoder(open("woody-snakeboots.mp3", "rb"))

switch = digitalio.DigitalInOut(board.GP2) # IT'S PIN 2!!
switch.direction = digitalio.Direction.INPUT
switch.pull = digitalio.Pull.DOWN


print("Starting loop")


while 1:
    if switch.value:
        print("Switch pressed, play audio")
        audio.play(decoder)
        while audio.playing:
            pass

    else:
        print("No switch press")

print("Exited while loop.")

