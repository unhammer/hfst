import hfst
transducers = []
ifile = open('testfile.att', 'r')
try:
    while (True):
        t = hfst.read_att_transducer(ifile, '<eps>')
        transducers.append(t)
        # print("read one transducer")
except hfst.exceptions.NotValidAttFormatException as e:
    print("Error reading transducer: not valid AT&T format.")
except hfst.exceptions.EndOfStreamException as e:
    pass
ifile.close()
assert(len(transducers) == 4)
# print("Read %i transducers in total" % len(transducers))
