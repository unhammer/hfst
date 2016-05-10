import hfst
f = open('cat.prolog', 'r')
tr = hfst.read_prolog_transducer(f)
print(tr)
