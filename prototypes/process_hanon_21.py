#!/usr/bin/env python

from align import nw_align


# load the score

score = []

for line in open("../examples/scores/hanon_21_rh.txt"):
    note = line.strip()
    note = int(note)
    score.append(note)


# load the performance

performance = []

for line in open("../examples/recordings/hanon_21_rh.txt"):
    offset, note, velocity = line.strip().split()
    offset = int(float(offset) * 1000000)
    note = int(note)
    velocity = int(velocity)
    
    if velocity > 0:
        performance.append((offset, note, velocity))


# similarity measure used by Needleman-Wunsch algorithm
def note_similarity(score_note, performance_note):
    
    # at the moment we just give a 1 if the pitch matches, 0.5 if it's
    # within a tone and 0 if more
    
    # over time this can be tweaked to include velocity, duration, etc
    
    if score_note == performance_note[1]:
        return 1
    elif abs(score_note - performance_note[1]) < 3:
        return 0.5
    else:
        return 0


# align score and performance using above similarity function and a penalty
# of -1 for insertions and deletions @@@ might need a lot of tweaking

for i in nw_align(score, performance, note_similarity, -1, -1):
    print i
