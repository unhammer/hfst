"""

Hfst Xerox-type rule functions.

"""

from libhfst import Rule, REPL_UP, REPL_DOWN, REPL_RIGHT, REPL_LEFT, \
replace, xerox_replace_left, replace_leftmost_longest_match, \
replace_rightmost_longest_match, replace_leftmost_shortest_match, \
replace_rightmost_shortest_match, replace_epenthesis, \
xerox_restriction, before, after
