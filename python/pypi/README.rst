
*******************
Package description
*******************

Package ``hfst`` contains python bindings for `HFST <https://hfst.github.io>`_ (Helsinki Finite-State Technology) C++ library. HFST toolkit is intended for processing natural language morphologies.
The toolkit is demonstrated by wide-coverage implementations of a number of languages of varying morphological complexity.

Requirements
############

The bindings work with python version 3.

Installation
############

Basic installation with ``pip``:

``pip install [--upgrade] hfst``

Starting from python 3.4, ``pip`` is included by default:

``python3 -m pip install [--upgrade] hfst``

We currently offer pypi wheels for 64-bit python versions 3.4 and 3.3 for OS X and Windows.

Alternative `installation instructions <https://kitwiki.csc.fi/twiki/bin/view/KitWiki/HfstPython>`_ are given on our KitWiki pages.

Documentation
#############

See Doxygen-generated `package documentation <https://hfst.github.io/python>`_ on our Github pages. In python, you can also use ``dir`` and ``help`` commands, e.g.:

``dir(hfst)``

``help(hfst.HfstTransducer)``

License
#######

HFST is licensed under Gnu GPL version 3.0.

Links
#####

`HFST project main page <https://hfst.github.io>`_: more information about the project

`Github issue tracker <https://github.com/hfst/hfst/issues/>`_: for comments, feature requests and bug reports

