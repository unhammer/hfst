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

tr1 = hfst.regex('föö:bär')
tr2 = hfst.regex('0')
tr3 = hfst.regex('0-0')

ostr = hfst.HfstOutputStream()
ostr.write(tr1)
ostr.write(tr2)
ostr.write(tr3)
ostr.flush()
ostr.close()
