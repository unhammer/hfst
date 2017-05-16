#!/bin/sh

## Copy files needed for a pypi distribution for linux or os x.
## copy-files-win.sh is the equivalent script for windows environment.

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Copy files needed for a pypi distribution on linux and OS X."
    echo ""
    echo "NOTE: flex/bison-generated cc and hh files are copied as such to"
    echo "avoid dependency on swig. Make sure you have a fresh version of them"
    echo "(run 'make' in top directory, if needed)."
    echo ""
    exit 0
fi

if ! [ -d "back-ends" ]; then mkdir back-ends; fi
if ! [ -d "libhfst" ]; then mkdir libhfst; fi
if ! [ -d "hfst" ]; then mkdir hfst; fi

cp -R ../../back-ends/* back-ends/
cp -R ../../libhfst/* libhfst/
cp -R ../hfst/* hfst/

for file in hfst_extensions.cc hfst_file_extensions.cc hfst_lexc_extensions.cc \
hfst_lookup_extensions.cc hfst_pmatch_extensions.cc hfst_prolog_extensions.cc \
hfst_regex_extensions.cc hfst_rules_extensions.cc hfst_xfst_extensions.cc \
hfst_sfst_extensions.cc libhfst.i docstrings.i ;
do
    cp ../$file $file
done
