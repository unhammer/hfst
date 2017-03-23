AM_CXXFLAGS= -Wcast-qual -Wno-deprecated -Wfatal-errors
bin_PROGRAMS=htwolcpre1 htwolcpre2 htwolcpre3 htwolc
bin_SCRIPTS=hfst-twolc hfst-twolc-loc
EXTRA_DIST=hfst-twolc.sh hfst-twolc.bat
AM_CPPFLAGS = -I${top_srcdir}/libhfst/src -I${top_srcdir}/libhfst/src/parsers
LDADD = $(top_builddir)/libhfst/src/libhfst.la

# the preprocessor scripts do not support options per se, so we whitelist
# them here
AM_INSTALLCHECK_STD_OPTIONS_EXEMPT=htwolcpre1 htwolcpre2 htwolcpre3 htwolc \
				hfst-twolc hfst-twolc-loc

htwolc_SOURCES=htwolc-main.cc
htwolcpre1_SOURCES=htwolcpre1-main.cc
htwolcpre2_SOURCES=htwolcpre2-main.cc
htwolcpre3_SOURCES=htwolcpre3-main.cc

hfst-twolc: hfst-twolc.sh
	cat $< | sed -e 's|BINDIR|$(bindir)|' > $@
	chmod ogu+rx hfst-twolc

hfst-twolc-loc: hfst-twolc.sh
	cat $< | sed -e 's|BINDIR|$(abs_builddir)|' > $@
	chmod ogu+rx hfst-twolc-loc

clean-local:
	-rm -f hfst-twolc hfst-twolc-loc
