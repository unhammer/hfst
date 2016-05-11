import hfst
import sys
f = open('cats_and_dogs.prolog', 'r')
F = open('cats_and_dogs.output.prolog', 'w')

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('{cat}')
assert(tr.compare(re))
tr.write_prolog(F, True)
F.write('\n')

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('0 - 0')
assert(tr.compare(re))
tr.write_prolog(F, True)
F.write('\n')

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('{dog}:{cat}::0.5')
assert(tr.compare(re))
tr.write_prolog(F, True)
F.write('\n')

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('[c a:h t:a 0:t]::-1.5')
assert(tr.compare(re))
tr.write_prolog(F, True)

try:
    tr = hfst.read_prolog_transducer(f)
    assert(False)
except hfst.exceptions.EndOfStreamException as e:
    pass

f.close()
F.close()

f = open('cats_and_dogs.output.prolog', 'r')

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('{cat}')
assert(tr.compare(re))

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('0 - 0')
assert(tr.compare(re))

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('{dog}:{cat}::0.5')
assert(tr.compare(re))

tr = hfst.read_prolog_transducer(f)
re = hfst.regex('[c a:h t:a 0:t]::-1.5')

try:
    tr = hfst.read_prolog_transducer(f)
    assert(False)
except hfst.exceptions.EndOfStreamException as e:
    pass

f.close()
