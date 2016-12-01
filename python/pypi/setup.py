#!/usr/bin/python3

"""
Setup for creating PIP packages for HFST Python bindings.

Before running setup, recursively copy directories 'libhfst/src'
and 'back-ends' from HFST c++ source code under the directory where
setup is run. Make sure that the following c++ and header files 
from 'libhfst/src/parsers' have been generated from flex/yacc
files before copying:

  lexc-parser.cc pmatch_parse.cc xfst-parser.cc xre_parse.cc
  lexc-parser.hh pmatch_parse.hh xfst-parser.hh xre_parse.hh

Compiling the extensions requires python, swig and a c++ compiler, 
all located on a directory listed on system PATH. On linux and mac 
osx, readline and getline must be available and the c++ compiler
must support flag 'std=c++0x'.

The setup script has been tested on linux with gcc 4.6.3 and
swig 2.0.4 (with python 3.2mu and 3.4m) and on windows with
msvc 10.0 and swig 3.0.5 (with python 3.3. and 3.4).

"""

import os
# from distutils.core import setup, Extension
from setuptools import setup, Extension
from sys import platform

# HFST C++ headers needed by swig when creating the python/c++ interface
swig_include_dir = "libhfst/src/"

ext_swig_opts = ["-c++", "-I" + swig_include_dir, "-Wall"]
if platform == "win32":
    ext_swig_opts = ["-c++", "-I" + swig_include_dir, "-Wall", 
                     "-IC:\\Program Files (x86)\\Microsoft SDKs\\Windows\\v7.0A\\Include"]
# todo: see if SDK directory is needed

# readline is needed for hfst.start_xfst(), on windows the shell where HFST
# python bindings are run from has its own readline which will do
ext_extra_link_args = []
if platform == "linux" or platform == "linux2" or platform == "darwin":
    ext_extra_link_args = ['-lreadline']

# HFST headers needed when compiling the actual c++ extension
ext_include_dirs = [".", "libhfst/src/", "back-ends/foma", "back-ends",
                    "parsers", "libhfst/src/parsers"]
if platform == "win32":
    ext_include_dirs.append("back-ends/openfstwin/src/include")
else:
    ext_include_dirs.append("back-ends/openfst/src/include")

# this replaces ./configure
ext_define_macros = [ ('HAVE_FOMA', None), ('HAVE_OPENFST', None),
                      ('HAVE_OPENFST_LOG', None) ]
if platform == "linux" or platform == "linux2" or platform == "darwin":
    ext_define_macros.append(('HAVE_READLINE', None))
    ext_define_macros.append(('HAVE_GETLINE', None))
if platform == "win32":
    for macro in ["HFSTEXPORT", "OPENFSTEXPORT", "_MSC_VER", "WINDOWS", "WIN32", "_CRT_SECURE_NO_WARNINGS"]:
        ext_define_macros.append((macro, None))

# use c++0x standard, if possible
ext_extra_compile_args = ['']
if platform == "linux" or platform == "linux2" or platform == "darwin":
    ext_extra_compile_args = ["-std=c++0x", "-Wno-sign-compare", "-Wno-strict-prototypes"]
# define error handling mechanism on windows
if platform == "win32":
    ext_extra_compile_args = ["/EHsc"]

ext_library_dirs = []
ext_libraries = []

# on windows, c++ source files have 'cpp' extension
cpp = ".cc"
if platform == "win32":
    cpp = ".cpp"

# on windows, openfst back-end is in directory 'openfstwin'
openfstdir = "openfst"
if platform == "win32":
    openfstdir = "openfstwin"

# all c++ extension source files
libhfst_source_files = ["libhfst/src/parsers/XfstCompiler" + cpp,
                        "libhfst/src/HfstApply" + cpp,
                        "libhfst/src/HfstInputStream" + cpp,
                        "libhfst/src/HfstTransducer" + cpp,
                        "libhfst/src/HfstOutputStream" + cpp,
                        "libhfst/src/HfstRules" + cpp,
                        "libhfst/src/HfstXeroxRules" + cpp,
                        "libhfst/src/HfstDataTypes" + cpp,
                        "libhfst/src/HfstSymbolDefs" + cpp,
                        "libhfst/src/HfstTokenizer" + cpp,
                        "libhfst/src/HfstFlagDiacritics" + cpp,
                        "libhfst/src/HfstExceptionDefs" + cpp,
                        "libhfst/src/HarmonizeUnknownAndIdentitySymbols" + cpp,
                        "libhfst/src/HfstLookupFlagDiacritics" + cpp,
                        "libhfst/src/HfstEpsilonHandler" + cpp,
                        "libhfst/src/HfstStrings2FstTokenizer" + cpp,
                        "libhfst/src/HfstPrintDot" + cpp,
                        "libhfst/src/HfstPrintPCKimmo" + cpp,
                        "libhfst/src/hfst-string-conversions" + cpp,
                        "libhfst/src/string-utils" + cpp,
                        "libhfst/src/implementations/HfstBasicTransducer" + cpp,
                        "libhfst/src/implementations/HfstBasicTransition" + cpp,
                        "libhfst/src/implementations/ConvertTransducerFormat" + cpp,
                        "libhfst/src/implementations/HfstTropicalTransducerTransitionData" + cpp,
                        "libhfst/src/implementations/ConvertTropicalWeightTransducer" + cpp,
                        "libhfst/src/implementations/ConvertLogWeightTransducer" + cpp,
                        "libhfst/src/implementations/ConvertFomaTransducer" + cpp,
                        "libhfst/src/implementations/ConvertOlTransducer" + cpp,
                        "libhfst/src/implementations/TropicalWeightTransducer" + cpp,
                        "libhfst/src/implementations/LogWeightTransducer" + cpp,
                        "libhfst/src/implementations/FomaTransducer" + cpp,
                        "libhfst/src/implementations/HfstOlTransducer" + cpp,
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectRulePair" + cpp,
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectLexicon" + cpp,
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectRule" + cpp,
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectFst" + cpp,
                        "libhfst/src/implementations/compose_intersect/ComposeIntersectUtilities" + cpp,
                        "libhfst/src/implementations/optimized-lookup/transducer" + cpp,
                        "libhfst/src/implementations/optimized-lookup/convert" + cpp,
                        "libhfst/src/implementations/optimized-lookup/ospell" + cpp,
                        "libhfst/src/implementations/optimized-lookup/pmatch" + cpp,
                        "libhfst/src/implementations/optimized-lookup/find_epsilon_loops" + cpp,
                        "libhfst/src/parsers/xre_lex" + cpp,
                        "libhfst/src/parsers/xre_parse" + cpp,
                        "libhfst/src/parsers/pmatch_parse" + cpp,
                        "libhfst/src/parsers/pmatch_lex" + cpp,
                        "libhfst/src/parsers/lexc-parser" + cpp,
                        "libhfst/src/parsers/lexc-lexer" + cpp,
                        "libhfst/src/parsers/xfst-parser" + cpp,
                        "libhfst/src/parsers/xfst-lexer" + cpp,
                        "libhfst/src/parsers/LexcCompiler" + cpp,
                        "libhfst/src/parsers/PmatchCompiler" + cpp,
                        "libhfst/src/parsers/XreCompiler" + cpp,
                        "libhfst/src/parsers/lexc-utils" + cpp,
                        "libhfst/src/parsers/pmatch_utils" + cpp,
                        "libhfst/src/parsers/xre_utils" + cpp,
                        "libhfst/src/parsers/xfst-utils" + cpp,
                        "libhfst/src/parsers/xfst_help_message" + cpp ]

foma_source_files = [ "back-ends/foma/int_stack.c",
                      "back-ends/foma/define.c",
                      "back-ends/foma/determinize.c",
                      "back-ends/foma/apply.c",
                      "back-ends/foma/rewrite.c",
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
                      "back-ends/foma/lex.yy.c",
                      "back-ends/foma/regex.c" ]

openfst_source_files =  [ "back-ends/" + openfstdir + "/src/lib/compat" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/flags" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/fst" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/properties" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/symbol-table" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/symbol-table-ops" + cpp,
                          "back-ends/" + openfstdir + "/src/lib/util" + cpp ]

# todo: see what files are actually needed...
# if platform == "linux" or platform == "linux2" or platform == "darwin":
#    foma_source_files.append("back-ends/foma/lexcread.c")
#    foma_source_files.append("back-ends/foma/lex.lexc.c")

libhfst_source_files = libhfst_source_files + openfst_source_files

if platform == "linux" or platform == "linux2" or platform == "win32":
    libhfst_source_files = libhfst_source_files + foma_source_files

# clang doesn't accept "-std=c++0x" flag when compiling C,
# so foma back-end must be compiled separately
foma_object_files = []
if platform == "darwin":
    import subprocess
    for file in foma_source_files:
        subprocess.call(["gcc", "-fPIC", "-std=c99", "-c", file])
        foma_object_files.append(file.replace('back-ends/foma/','').replace('.c','.o'))

# The HFST c++ extension
libhfst_module = Extension('_libhfst',
                           language = "c++",
                           sources = ["libhfst.i"] + libhfst_source_files,
                           swig_opts = ext_swig_opts,
                           include_dirs = ext_include_dirs,
                           library_dirs = ext_library_dirs,
                           libraries = ext_libraries,
                           define_macros = ext_define_macros,
                           extra_link_args = ext_extra_link_args,
                           extra_compile_args = ext_extra_compile_args,
                           extra_objects = foma_object_files
                           )

setup(name = 'hfst',
      version = '3.12.1.0_beta',
      author = 'HFST team',
      author_email = 'hfst-bugs@helsinki.fi',
      url = 'http://hfst.github.io/',
      description = 'SWIG-bound hfst interface',
      license = 'GNU GPL3',
      ext_modules = [libhfst_module],
      py_modules = ["libhfst"],
      packages = ["hfst", "hfst.exceptions", "hfst.sfst_rules", "hfst.xerox_rules"],
      data_files = []
      )
