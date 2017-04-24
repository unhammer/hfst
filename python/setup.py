#!/usr/bin/python

"""
setup for HFST-swig
"""

import os
from distutils.core import setup, Extension
from sys import platform

libhfst_src_path = '../libhfst/src/'
absolute_libhfst_src_path = os.path.abspath(libhfst_src_path)

extra_link_arguments = []
if platform == "darwin":
        extra_link_arguments.extend(['-mmacosx-version-min=10.7'])

# If you wish to link to the local HFST library:
# extra_link_arguments.extend(["-Wl,-rpath=" + absolute_libhfst_src_path + "/.libs"])
#
# When making the debian package:
# extra_link_arguments.extend(["-L/usr/lib/", "-Wl,-rpath=/usr/lib/"])

extra_compile_arguments = ['-std=c++0x']
if platform == "darwin":
        extra_compile_arguments.extend('["-stdlib=libc++", "-mmacosx-version-min=10.7"]')

# If you wish to link hfst c++ library statically, use:
# library_dirs = []
# libraries = []
# extra_objects = absolute_libhfst_src_path + "/.libs/libhfst.a"

libhfst_module = Extension('_libhfst',
                           language = "c++",
                           sources = ["libhfst.i"],
                           swig_opts = ["-c++",
                                        "-I" + absolute_libhfst_src_path, "-Wall"],
                           include_dirs = [absolute_libhfst_src_path],
                           library_dirs = [absolute_libhfst_src_path + "/.libs"],
                           libraries = ["hfst"],
                           extra_compile_args = extra_compile_arguments,
                           extra_link_args = extra_link_arguments
                           )
# When making the windows package, replace data_files with
# ["libhfst-NN.dll", "libgcc_s_seh-1.dll"] or
# ["libhfst-NN.dll", "libgcc_s_dw2-1.dll"] or
setup(name = 'libhfst_swig',
      version = '3.12.2_beta',
      author = 'HFST team',
      author_email = 'hfst-bugs@helsinki.fi',
      url = 'http://hfst.github.io/',
      description = 'SWIG-bound hfst interface',
      ext_modules = [libhfst_module],
      py_modules = ["libhfst"],
      packages = ["hfst", "hfst.exceptions", "hfst.sfst_rules", "hfst.xerox_rules"],
      data_files = []
      )
