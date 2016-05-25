import hfst
import sys

if sys.argv[1] == 'sfst':
    if not hfst.HfstTransducer.is_implementation_type_available(hfst.types.SFST_TYPE):
        sys.exit(77)
    hfst.set_default_fst_type(hfst.types.SFST_TYPE)
elif sys.argv[1] == 'foma':
    if not hfst.HfstTransducer.is_implementation_type_available(hfst.types.FOMA_TYPE):
        sys.exit(77)
    hfst.set_default_fst_type(hfst.types.FOMA_TYPE)
elif sys.argv[1] == 'openfst':
    if not hfst.HfstTransducer.is_implementation_type_available(hfst.types.TROPICAL_OPENFST_TYPE):
        sys.exit(77)
    hfst.set_default_fst_type(hfst.types.TROPICAL_OPENFST_TYPE)
else:
    raise RuntimeError('implementation format not recognized')

transducers = []

try:
    while (True):
        transducers.append(hfst.read_att_transducer(sys.stdin))
except hfst.exceptions.EndOfStreamException:
    pass

if not len(transducers) == 3:
    raise RuntimeError('Wrong number of transducers read.')

i = 0
for re in ['föö:bär','0','0-0']:
    if not transducers[i].compare(hfst.regex(re)):
        raise RuntimeError('Transducers are not equivalent.')
    i += 1
