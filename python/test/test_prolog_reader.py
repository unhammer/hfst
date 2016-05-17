import hfst

transducers = []

with open('cats_and_dogs.prolog', 'r') as f:
    r = hfst.PrologReader(f)
    for tr in r:
        transducers.append(tr)

assert(f.closed)
assert(len(transducers)) == 4

transducers = []

with open('cats_and_dogs_fail.prolog', 'r') as f:
    try:
        r = hfst.PrologReader(f)
        for tr in r:
            transducers.append(tr)
    except hfst.exceptions.NotValidPrologFormatException as e:
        pass

assert(f.closed)
assert(len(transducers)) == 4
