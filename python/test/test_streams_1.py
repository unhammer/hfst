import hfst

tr1 = hfst.regex('föö:bär')
tr2 = hfst.regex('0')
tr3 = hfst.regex('0-0')

ostr = hfst.HfstOutputStream()
ostr.write(tr1)
ostr.write(tr2)
ostr.write(tr3)
ostr.flush()
ostr.close()
