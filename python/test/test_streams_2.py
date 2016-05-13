import hfst
import sys

if sys.argv[1] == 'sfst':
    hfst.set_default_fst_type(hfst.SFST_TYPE)
elif sys.argv[1] == 'foma':
    hfst.set_default_fst_type(hfst.FOMA_TYPE)
elif sys.argv[1] == 'openfst':
    hfst.set_default_fst_type(hfst.TROPICAL_OPENFST_TYPE)
else:
    raise RuntimeError('implementation format not recognized')

transducers = []
istr = hfst.HfstInputStream()
while not istr.is_eof():
    transducers.append(istr.read())
istr.close()

if not len(transducers) == 3:
    raise RuntimeError('Wrong number of transducers read.')

i = 0
for re in ['föö:bär','0','0-0']:
    if not transducers[i].compare(hfst.regex(re)):
        raise RuntimeError('Transducers are not equivalent.')
    i += 1

if len(transducers) > 0:
    f = sys.stdout
    i=0
    transducers[i].write_att(f)
    i += 1
    while i < len(transducers):
        f.write('--\n')
        transducers[i].write_att(f)
        i += 1
