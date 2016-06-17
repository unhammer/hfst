#!/usr/bin/python

"""
setup for HFST-swig
"""

import os
from distutils.core import setup, Extension

libhfst_src_path = '../libhfst/src/'
absolute_libhfst_src_path = os.path.abspath(libhfst_src_path)

extra_link_arguments = []
# If you wish to link to the local HFST library, replace the above with:
# extra_link_arguments = ["-Wl,-rpath=" + absolute_libhfst_src_path + "/.libs"]

# When making the debian package, replace extra_link_args
# with ["-L/usr/lib/", "-Wl,-rpath=/usr/lib/"]
libhfst_module = Extension('_libhfst',
                           language = "c++",
                           sources = ["libhfst.i"],
                           swig_opts = ["-c++",
                                        "-I" + absolute_libhfst_src_path, "-Wall"],
                           include_dirs = [absolute_libhfst_src_path],
                           library_dirs = [absolute_libhfst_src_path + "/.libs"],
                           libraries = ["hfst"],
                           extra_link_args = extra_link_arguments
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
      ext_modules = [libhfst_module],
      py_modules = ["libhfst"],
      packages = ["hfst", "hfst.exceptions", "hfst.rules", "hfst.types"],
      data_files = []
      )
