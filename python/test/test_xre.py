import hfst

comp = hfst.XreCompiler(hfst.get_default_fst_type())
comp.set_expand_definitions(True)
comp.define_xre('FooStar', '[foo]*')
tr = hfst.regex('[foo]+')
comp.define_transducer('FooPlus', tr)
comp.define_xre('Bar', 'bar')
comp.undefine('Bar')

TR = comp.compile('FooStar a FooPlus Bar')
TR1 = hfst.regex('[foo* a foo+ Bar]')
assert TR1.compare(TR)
