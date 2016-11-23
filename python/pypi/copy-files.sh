#!/bin/sh

cp -R ../../back-ends back-ends
cp -R ../../libhfst libhfst
cp -R ../hfst hfst

for file in hfst_extensions.cc hfst_file_extensions.cc hfst_lexc_extensions.cc \
hfst_lookup_extensions.cc hfst_pmatch_extensions.cc hfst_prolog_extensions.cc \
hfst_regex_extensions.cc hfst_rules_extensions.cc hfst_xfst_extensions.cc \
libhfst.i docstrings.i ;
do
    cp ../$file $file
done
