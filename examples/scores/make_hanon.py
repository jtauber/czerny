#!/usr/bin/env python

# right-hand of Hanon 21

# @@@ this will eventually be rewritten in Sebastian

# upward
A_notes = [1, 2, 3, 2, 1, 3, 4, 5, 6, 5, 4, 5, 6, 5, 4, 3]
A_fingering = [1, 2, 3, 2, 1, 2, 3, 4, 5, 4, 3, 4, 5, 4, 3, 2]

# downward except for last bar
B_notes = [6, 5, 4, 5, 6, 4, 3, 2, 1, 2, 3, 2, 1, 2, 3, 4]
B_fingering = [5, 4, 3, 4, 5, 4, 3, 2, 1, 2, 3, 2, 1, 2, 3, 4]

# last bar
C_notes = [6, 5, 4, 5, 6, 4, 3, 2, 1, 2, 3, 2, 1, 2, 3, 2]
C_fingering = [5, 4, 3, 4, 5, 4, 3, 2, 1, 2, 3, 2, 1, 2, 3, 2]

# final note
D_notes = [1]
D_fingering = [1]

scale = [0, 2, 4, 5, 7, 9, 11]

full_scale = scale + [12 + i for i in scale] + [24 + i for i in scale]

sections = [
    (A_notes, 4, [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13]),
    (B_notes, 4, [13, 12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, 1]),
    (C_notes, 4, [0]),
    (D_notes, 32, [0])
]

for section in sections:
    pattern, duration_64, offset = section
    for o in offset:
        for note in pattern:
            print 48 + full_scale[note + o - 1], duration_64
