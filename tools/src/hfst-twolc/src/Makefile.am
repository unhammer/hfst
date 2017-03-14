AM_CXXFLAGS= -Wcast-qual -Wno-deprecated -Wfatal-errors
bin_PROGRAMS=htwolcpre1 htwolcpre2 htwolcpre3 htwolc hfst-twolc-system
bin_SCRIPTS=hfst-twolc hfst-twolc-loc
EXTRA_DIST=hfst-twolc.sh hfst-twolc.bat
AM_CPPFLAGS = -I${top_srcdir}/libhfst/src -I${top_srcdir}/libhfst/src/parsers
LDADD = $(top_builddir)/libhfst/src/libhfst.la

# the preprocessor scripts do not support options per se, so we whitelist
# them here
AM_INSTALLCHECK_STD_OPTIONS_EXEMPT=htwolcpre1 htwolcpre2 htwolcpre3 htwolc \
				hfst-twolc hfst-twolc-loc hfst-twolc-system$(EXEEXT)

#CL_SRC=$(srcdir)/commandline_src

htwolc_SOURCES=htwolc-main.cc # $(CL_SRC)/CommandLine.cc $(CL_SRC)/CommandLine.h
htwolcpre1_SOURCES=htwolcpre1-main.cc # $(CL_SRC)/CommandLine.cc $(CL_SRC)/CommandLine.h
htwolcpre2_SOURCES=htwolcpre2-main.cc # $(CL_SRC)/CommandLine.cc $(CL_SRC)/CommandLine.h
htwolcpre3_SOURCES=htwolcpre3-main.cc # $(CL_SRC)/CommandLine.cc $(CL_SRC)/CommandLine.h
hfst_twolc_system_SOURCES=hfst-twolc-system.cc

hfst-twolc: hfst-twolc.sh
	cat $< | sed -e 's|BINDIR|$(bindir)|' > $@
	chmod ogu+rx hfst-twolc

hfst-twolc-loc: hfst-twolc.sh
	cat $< | sed -e 's|BINDIR|$(abs_builddir)|' > $@
	chmod ogu+rx hfst-twolc-loc

clean-local:
	-rm -f hfst-twolc hfst-twolc-loc hfst-twolc-system$(EXEEXT)
