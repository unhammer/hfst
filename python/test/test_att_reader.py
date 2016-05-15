import hfst

transducers = []

with open('testfile.att', 'r') as f:
    r = hfst.AttReader(f, "<eps>")
    for tr in r:
        transducers.append(tr)

assert(f.closed)
assert(len(transducers)) == 4

transducers = []

with open('testfile_fail.att', 'r') as f:
    try:
        r = hfst.AttReader(f, "<eps>")
        for tr in r:
            transducers.append(tr)
    except hfst.exceptions.NotValidAttFormatException as e:
        pass

assert(f.closed)
assert(len(transducers)) == 4
