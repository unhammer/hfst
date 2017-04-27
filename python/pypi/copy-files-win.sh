#!/bin/sh

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "(For windows:) copy files needed for pypi distribution."
    echo ""
    exit 0
fi

if ! [ -d "back-ends" ]; then mkdir back-ends; fi
if ! [ -d "libhfst" ]; then mkdir libhfst; fi
if ! [ -d "hfst" ]; then mkdir hfst; fi
if ! [ -d "test" ]; then mkdir test; fi

cp -R ../../back-ends/* back-ends/
cp -R ../../libhfst/* libhfst/
cp -R ../hfst/* hfst/
cp -R ../test/* test/

# files under ../
for file in hfst_extensions.cc hfst_file_extensions.cc hfst_lexc_extensions.cc \
hfst_lookup_extensions.cc hfst_pmatch_extensions.cc hfst_prolog_extensions.cc \
hfst_regex_extensions.cc hfst_rules_extensions.cc hfst_xfst_extensions.cc \
hfst_sfst_extensions.cc libhfst.i docstrings.i ;
do
    cp ../$file $file
done

# .cc -> .cpp
for dir in back-ends libhfst;
do
    find $dir -name "*.cc" | sed 's/\(.*\).cc/mv \1.cc \1.cpp/' | sh
done

# unistd.h -> io.h
for file in xfst-lexer htwolcpre1-lexer htwolcpre2-lexer htwolcpre3-lexer sfst-scanner pmatch_lex lexc-lexer xre_lex;
do
    sed -i 's/#include <unistd.h>/#include <io.h>/' libhfst/src/parsers/$file.cpp
done
for file in lex.cmatrix.c lex.yy.c;
do
    sed -i 's/#include <unistd.h>/#include <io.h>/' back-ends/foma/$file
done

# h.*wrap( ) -> h.*wrap(void)
sed -i 's/hxfstwrap( )/hxfstwrap(void)/' libhfst/src/parsers/xfst-lexer.cpp
sed -i 's/pmatchwrap( )/pmatchwrap(void)/' libhfst/src/parsers/pmatch_lex.cpp
sed -i 's/hlexcwrap( )/hlexcwrap(void)/' libhfst/src/parsers/lexc-lexer.cpp

# copy windows-scpecific headers
cp ../../scripts/windows/stdint.h back-ends/foma/stdint.h
cp ../../scripts/windows/inttypes.h back-ends/foma/inttypes.h
