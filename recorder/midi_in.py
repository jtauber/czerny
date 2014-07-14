#!/usr/bin/env python

from mac import CoreMIDI
import time

# all times will be offset from when we started this script
start = time.time()


# handle MIDI event callback
def callback(event):
    # only worry about event type 156
    if event[0] == 156:
        # write out offset, midi_pitch, velocity (0 for note off)
        print time.time() - start, event[1], event[2]

# hook up callback
CoreMIDI.pyCallback = callback

# loop forever
while True:
    pass
