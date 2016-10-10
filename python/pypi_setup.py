#!/usr/bin/python

"""
setup for HFST-swig
"""

import os
from distutils.core import setup, Extension
#from setuptools import setup, Extension

libhfst_src_path = '../libhfst/src/'
absolute_libhfst_src_path = os.path.abspath(libhfst_src_path)

# When creating pypi packages
swig_include_dir = "libhfst/src/"
# else
swig_include_dir = absolute_libhfst_src_path

# When creating pypi packages
ext_extra_link_args = ['-lreadline']
# else
ext_extra_link_args = []

# When creating pypi packages
ext_include_dirs = [".", "libhfst/src/", "back-ends/foma", "back-ends", 
                    "back-ends/openfst/src/include",
                    "parsers", "libhfst/src/parsers"]
# else
ext_include_dirs = [absolute_libhfst_src_path]

# When creating pypi packages
ext_define_macros = [ ('HAVE_FOMA', None), ('HAVE_OPENFST', None),
                      ('HAVE_OPENFST_LOG', None), ('HAVE_GETLINE', None),
                      ('HAVE_READLINE', None) ]
# else
ext_define_macros = []

# When creating pypi packages
ext_extra_compile_args = ["-std=c++0x"]
# else
ext_extra_compile_args = []

# When creating pypi packages
ext_library_dirs = []
ext_libraries = []
# else
ext_library_dirs = [absolute_libhfst_src_path + "/.libs"]
ext_libraries = ["hfst"],

# These are needed when creating pypi packages
libhfst_source_files = ["libhfst/src/parsers/XfstCompiler.cc",
                        "libhfst/src/HfstApply.cc",
                        "libhfst/src/HfstInputStream.cc",
                        "libhfst/src/HfstTransducer.cc",
                        "libhfst/src/HfstOutputStream.cc",
                        "libhfst/src/HfstRules.cc",
                        "libhfst/src/HfstXeroxRules.cc",
                        "libhfst/src/HfstDataTypes.cc",
                        "libhfst/src/HfstSymbolDefs.cc",
                        "libhfst/src/HfstTokenizer.cc",
                        "libhfst/src/HfstFlagDiacritics.cc",
                        "libhfst/src/HfstExceptionDefs.cc",
                        "libhfst/src/HarmonizeUnknownAndIdentitySymbols.cc",
                        "libhfst/src/HfstLookupFlagDiacritics.cc",
                        "libhfst/src/HfstEpsilonHandler.cc",
                        "libhfst/src/HfstStrings2FstTokenizer.cc",
                        "libhfst/src/HfstPrintDot.cc",
                        "libhfst/src/HfstPrintPCKimmo.cc",
                        "libhfst/src/hfst-string-conversions.cc",
                        "libhfst/src/string-utils.cc",
                        "libhfst/src/implementations/HfstBasicTransducer.cc",
                        "libhfst/src/implementations/HfstBasicTransition.cc",
                        "libhfst/src/implementations/ConvertTransducerFormat.cc",
                        "libhfst/src/implementations/HfstTropicalTransducerTransitionData.cc",
                        "libhfst/src/implementations/ConvertTropicalWeightTransducer.cc",
                        "libhfst/src/implementations/ConvertLogWeightTransducer.cc",
                        "libhfst/src/implementations/ConvertFomaTransducer.cc",
                        "libhfst/src/implementations/ConvertOlTransducer.cc",
                        "libhfst/src/implementations/TropicalWeightTransducer.cc",
                        "libhfst/src/implementations/LogWeightTransducer.cc",
                        "libhfst/src/implementations/FomaTransducer.cc",
                        "libhfst/src/implementations/HfstOlTransducer.cc",
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectRulePair.cc",
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectLexicon.cc",
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectRule.cc",
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectFst.cc",
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectUtilities.cc",
                        "libhfst/src/implementations/optimized-lookup/transducer.cc",
                        "libhfst/src/implementations/optimized-lookup/convert.cc",
                        "libhfst/src/implementations/optimized-lookup/ospell.cc",
                        "libhfst/src/implementations/optimized-lookup/pmatch.cc",
                        "libhfst/src/implementations/optimized-lookup/find_epsilon_loops.cc",
                        "libhfst/src/parsers/xre_lex.cc",
                        "libhfst/src/parsers/xre_parse.cc",
                        "libhfst/src/parsers/pmatch_parse.cc",
                        "libhfst/src/parsers/pmatch_lex.cc",
                        "libhfst/src/parsers/lexc-parser.cc",
                        "libhfst/src/parsers/lexc-lexer.cc",
                        "libhfst/src/parsers/xfst-parser.cc",
                        "libhfst/src/parsers/xfst-lexer.cc",
                        "libhfst/src/parsers/LexcCompiler.cc",
                        "libhfst/src/parsers/PmatchCompiler.cc",
                        "libhfst/src/parsers/XreCompiler.cc",
                        "libhfst/src/parsers/lexc-utils.cc",
                        "libhfst/src/parsers/pmatch_utils.cc",
                        "libhfst/src/parsers/xre_utils.cc",
                        "libhfst/src/parsers/xfst-utils.cc",
                        "libhfst/src/parsers/xfst_help_message.cc",
                        "back-ends/openfst/src/lib/compat.cc",
                        "back-ends/openfst/src/lib/flags.cc",
                        "back-ends/openfst/src/lib/fst.cc",
                        "back-ends/openfst/src/lib/properties.cc",
                        "back-ends/openfst/src/lib/symbol-table.cc",
                        "back-ends/openfst/src/lib/symbol-table-ops.cc",
                        "back-ends/openfst/src/lib/util.cc",
                        "back-ends/foma/int_stack.c",
                        "back-ends/foma/define.c",
                        "back-ends/foma/determinize.c",
                        "back-ends/foma/apply.c",
                        "back-ends/foma/rewrite.c",
                        "back-ends/foma/lexcread.c",
                        "back-ends/foma/topsort.c",
                        "back-ends/foma/flags.c",
                        "back-ends/foma/minimize.c",
                        "back-ends/foma/reverse.c",
                        "back-ends/foma/extract.c",
                        "back-ends/foma/sigma.c",
                        "back-ends/foma/structures.c",
                        "back-ends/foma/constructions.c",
                        "back-ends/foma/coaccessible.c",
                        "back-ends/foma/io.c",
                        "back-ends/foma/utf8.c",
                        "back-ends/foma/spelling.c",
                        "back-ends/foma/dynarray.c",
                        "back-ends/foma/mem.c",
                        "back-ends/foma/stringhash.c",
                        "back-ends/foma/trie.c",
                        "back-ends/foma/lex.lexc.c",
                        "back-ends/foma/lex.yy.c",
                        "back-ends/foma/regex.c"]
# else
libhfst_source_files = []

# If you wish to link to the local HFST library, replace the above with:
# extra_link_arguments = ["-Wl,-rpath=" + absolute_libhfst_src_path + "/.libs"]

# When making the debian package, replace extra_link_args
# with ["-L/usr/lib/", "-Wl,-rpath=/usr/lib/"]

# If you wish to link hfst c++ library statically, use:
# library_dirs = []
# libraries = []
# extra_objects = absolute_libhfst_src_path + "/.libs/libhfst.a"

libhfst_module = Extension('_libhfst',
                           language = "c++",
                           sources = ["libhfst.i"] + libhfst_source_files,
                           swig_opts = ["-c++",
                                        "-I" + swig_include_dir, "-Wall"],
                           include_dirs = ext_include_dirs,
                           library_dirs = ext_library_dirs,
                           libraries = ext_libraries,
                           extra_link_args = ext_extra_link_args,
                           extra_compile_args = ext_extra_compile_args
                           )

# When making the windows package, replace data_files with
# ["libhfst-NN.dll", "libgcc_s_seh-1.dll"] or
# ["libhfst-NN.dll", "libgcc_s_dw2-1.dll"] or

setup(name = 'libhfst_swig',
      version = '3.11.0_beta',
      author = 'HFST team',
      author_email = 'hfst-bugs@helsinki.fi',
      url = 'http://hfst.github.io/',
      description = 'SWIG-bound hfst interface',
      license = 'GNU GPL3',
      ext_modules = [libhfst_module],
      py_modules = ["libhfst"],
      packages = ["hfst", "hfst.exceptions", "hfst.rules", "hfst.types"],
      data_files = []
      )
