"""

Hfst Xerox-type rule functions and classes.

"""

from libhfst import Rule, \
replace, replace_leftmost_longest_match, \
replace_rightmost_longest_match, replace_leftmost_shortest_match, \
replace_rightmost_shortest_match, replace_epenthesis, \
before, after, ReplaceType

# these functions had to be renamed in the swig interface
# to prevent name collision
from libhfst import xerox_replace_left as replace_left
from libhfst import xerox_restriction as restriction
