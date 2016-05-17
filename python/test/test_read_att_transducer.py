import hfst

for type in [hfst.SFST_TYPE, hfst.TROPICAL_OPENFST_TYPE, hfst.FOMA_TYPE]:
    if hfst.HfstTransducer.is_implementation_type_available(type):

        transducers = []
        ifile = open('testfile.att', 'r')
        try:
            while (True):
                t = hfst.read_att_transducer(ifile, '<eps>')
                transducers.append(t)
        except hfst.exceptions.NotValidAttFormatException as e:
            print("Error reading transducer: not valid AT&T format.")
        except hfst.exceptions.EndOfStreamException as e:
            pass
        ifile.close()
        assert(len(transducers) == 4)

