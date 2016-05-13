import hfst

import os.path
assert os.path.isfile('streets.txt')

# pmatch transducers are always in ol format, so this has actually no effect...
for type in [hfst.SFST_TYPE, hfst.TROPICAL_OPENFST_TYPE, hfst.FOMA_TYPE]:
    if hfst.HfstTransducer.is_implementation_type_available(type):
        print(hfst.fst_type_to_string(type))
        hfst.set_default_fst_type(type)
        defs = hfst.compile_pmatch_file('streets.txt')
        cont = hfst.PmatchContainer(defs)
        assert cont.match("Je marche seul dans l'avenue des Ternes.") == "Je marche seul dans l'<FrenchStreetName>avenue des Ternes</FrenchStreetName>."
        
        nonexistent_file = 'foofoofoofoofoofoofoofoofoofoofoofoo'
        
        assert not os.path.isfile(nonexistent_file)
        try:
            hfst.compile_pmatch_file(nonexistent_file)
            assert False
        except IOError as e:
            pass


