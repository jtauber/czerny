#!/usr/bin/env python

from align import nw_align


def load_score(filename):

    score = []
    
    for line in open(filename):
        note, duration_64 = line.strip().split()
        note = int(note)
        duration_64 = int(duration_64)
        score.append((note, duration_64))
    
    return score


def load_performance(filename):
    
    performance = []
    
    # dictionary mapping pitch to offset and velocity of event when that pitch was started
    note_started = {}
    
    for line in open(filename):
        offset, note, velocity = line.strip().split()
        offset = int(float(offset) * 1000000)
        note = int(note)
        velocity = int(velocity)
        
        if velocity > 0:
            if note in note_started:
                # new note at that pitch started before previous finished
                # not sure it should happen but let's handle it anyway
                (start_offset, start_velocity) = note_started.pop(note)
                duration = offset - start_offset
                performance.append((start_offset, note, start_velocity, duration))
            note_started[note] = (offset, velocity)
        else: # note end
            if note not in note_started:
                # note was never started so ignore
                pass
            else:
                (start_offset, start_velocity) = note_started.pop(note)
                duration = offset - start_offset
                performance.append((start_offset, note, start_velocity, duration))
    
    return performance


# similarity measure used by Needleman-Wunsch algorithm
def note_similarity(score_note, performance_note):
    
    # at the moment we just give a 1 if the pitch matches, 0.5 if it's
    # within a tone and 0 if more
    
    # over time this can be tweaked to include velocity, duration, etc
    
    if score_note[0] == performance_note[1]:
        return 1
    elif abs(score_note[0] - performance_note[1]) < 3:
        return 0.5
    else:
        return 0


if __name__ == "__main__":
    
    score = load_score("../examples/scores/hanon_21_rh.txt")
    performance = load_performance("../examples/recordings/hanon_21_rh.txt")
    
    # align score and performance using above similarity function and a penalty
    # of -1 for insertions and deletions @@@ might need a lot of tweaking
    
    for i in nw_align(score, performance, note_similarity, -1, -1):
        print i
