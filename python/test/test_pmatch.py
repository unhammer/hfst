import libhfst
import os.path

assert os.path.isfile('streets.txt')
libhfst.compile_pmatch_file('streets.txt','streets.pmatch')
assert os.path.isfile('streets.pmatch')
cont = libhfst.PmatchContainer('streets.pmatch')
assert cont.match("Je marche seul dans l'avenue des Ternes.") == "Je marche seul dans l'<FrenchStreetName>avenue des Ternes</FrenchStreetName>."

nonexistent_file1 = 'foofoofoofoofoofoofoofoofoofoofoofoo'
nonexistent_file2 = 'barbarbarbarbarbarbarbarbarbarbarbar'

assert not os.path.isfile(nonexistent_file1)
try:
    libhfst.compile_pmatch_file(nonexistent_file1,nonexistent_file2)
    assert False
except IOError as e:
    pass
assert not os.path.isfile(nonexistent_file2)
