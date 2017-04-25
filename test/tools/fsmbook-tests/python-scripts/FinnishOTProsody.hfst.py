exec(compile(open('CompileOptions.py', 'rb').read(), 'CompileOptions.py', 'exec'))

defs = {}

def regex(expr):
    return hfst.regex(expr, definitions=defs)

# Data
defs['FinnWords'] = regex("{kalastelet} | {kalasteleminen} | {ilmoittautuminen} | \
                 {järjestelmättömyydestänsä} | {kalastelemme} | \
                 {ilmoittautumisesta} | {järjestelmällisyydelläni} | \
                 {järjestelmällistämätöntä} | {voimisteluttelemasta} | \
                 {opiskelija} | {opettamassa} | {kalastelet} | \
                 {strukturalismi} | {onnittelemanikin} | {mäki} | \
                 {perijä} | {repeämä} | {ergonomia} | {puhelimellani} | \
                 {matematiikka} | {puhelimistani} | {rakastajattariansa} | \
                 {kuningas} | {kainostelijat} | {ravintolat} | \
                 {merkonomin} ;")

# Basic definitions

defs['HighV'] = regex('[u | y | i]')                          # High vowel
defs['MidV'] = regex('[e | o | ö]')                          # Mid vowel
defs['LowV'] = regex('[a | ä]')                             # Low vowel
defs['USV'] = regex('[HighV | MidV | LowV]')                  # Unstressed Vowel

defs['C'] = regex("[b | c | d | f | g | h | j | k | l | m | n | p | q | r | s | t | v | w | x | z]")  # Consonant

defs['MSV'] = regex('[á | é | í | ó | ú | ý | ä´ | ö´ ]')
defs['SSV'] = regex('[à | è | ì | ò | ù | y` | ä` | ö`]')
defs['SV'] = regex('[MSV | SSV]')                              # Stressed vowel
defs['V'] = regex('[USV | SV] ')                               # Vowel

defs['P'] = regex('[V | C]')                                   # Phone
defs['B'] = regex('[[\P+] | .#. ]')                             # Boundary

defs['E'] = regex('.#. | "."')                                 # Edge
defs['SB'] = regex('[~$"." "." ~$"."]')                        # At most one syllable boundary

defs['Light'] = regex('[C* V]')                                # Light syllable
defs['Heavy'] = regex('[Light P+]')                            # Heavy syllable

defs['S'] = regex('[Heavy | Light]')                           # Syllable
defs['SS'] = regex('[S & $SV]')                                # Stressed syllable

defs['US'] = regex('[S & ~$SV]')                               # Unstressed syllable
defs['MSS'] = regex('[S & $MSV] ')                             # Syllable with main stress
defs['BF'] = regex('[S "." S]')                                # Binary foot


# Gen
#echo "-- GEN ---"

# A diphthong is a combination of two unlike vowels that together form
# the nucleus of a syllable. In general, Finnish diphthongs end in a high vowel.
# However, there are three exceptional high-mid diphthongs: ie, uo, and yö
# that historically come from long ee, oo, and öö, respectively.
# All other adjacent vowels must be separated by a syllable boundary.

defs['MarkNonDiphthongs'] = regex(' [. .] -> "." || [HighV | MidV] _ LowV , i _ [MidV - e] , u _ [MidV - o] , y _ [MidV - ö] ;')

# The general syllabification rule has exceptions. In particular, loan
# words such as ate.isti 'atheist' must be partially syllabified in the
# lexicon.


defs['Syllabify'] = regex('C* V+ C* @-> ... "." || _ C V')


# Optionally adds primary or secondary stress to the first vowel
# of each syllable.

defs['Stress'] = regex('a (->) á|à , e (->) é|è , i (->) í|ì , o (->) ó|ò , u (->) ú|ù , y (->) ý|y` , ä (->) ä´|ä` , ö (->) ö´|ö` || E C* _ ')
              

# Scan the word, optionally dividing it to any combination of
# unary, binary, and ternary feet. Each foot must contain at least
# one stressed syllable.


defs['Scan'] = regex('[[S ("." S ("." S)) & $SS] (->) "(" ... ")" || E _ E]')

# In keeping with the idea of "richness of the base", the Gen
# function produces a great number of output candidates for
# even short words. Long words have millions of possible outputs.

defs['Gen'] = regex('[MarkNonDiphthongs .o. Syllabify .o. Stress .o. Scan]')

# OT constraints

#echo "--- OT constraints --- "

# We use asterisks to mark constraint violations. Ordinary constraints
# such as Lapse assign single asterisks as the violation marks and the
# candidate with the fewest number is selected. Gradient constraints
# such as AllFeetFirst mark violations with sequences of asterisks.
# The number increases with distance from the word edge.

# Every instance of * in an output candidate is a violation.

defs['Viol'] = regex('${*}')



# We prune candidates with "lenient composition" that eliminates
# candidates that violate the constraint provided that at least
# one output candidate survives.

defs['Viol0'] = regex('~Viol')         # No violations
defs['Viol1'] = regex('~[Viol^2]')     # At most one violation
defs['Viol2'] = regex('~[Viol^3]')     # At most two violations
defs['Viol3'] = regex('~[Viol^4]')     # etc.
defs['Viol4'] = regex('~[Viol^5]')
defs['Viol5'] = regex('~[Viol^6]')
defs['Viol6'] = regex('~[Viol^7]')
defs['Viol7'] = regex('~[Viol^8]')
defs['Viol8'] = regex('~[Viol^9]')
defs['Viol9'] = regex('~[Viol^10]')
defs['Viol10'] = regex('~[Viol^11]')
defs['Viol11'] = regex('~[Viol^12]')
defs['Viol12'] = regex('~[Viol^13]')
defs['Viol13'] = regex('~[Viol^14]')
defs['Viol14'] = regex('~[Viol^15]')
defs['Viol15'] = regex('~[Viol^16]')




# This eliminates the violation marks after the candidate set has
# been pruned by a constraint.

defs['Pardon'] = regex('{*} -> 0')




# Constraints

#echo "CONSTRAINTS---"

# In this section we define nine constraints for Finnish prosody,
# listed in the order of their ranking: MainStress, Clash, AlignLeft,
# FootBin, Lapse, NonFinal, StressToWeight, Parse, and AllFeetFirst.
# For the one inviolable constraint, we assign no violation marks.
# Clash, Align-Left and Foot-Bin are always satisfiable in Finnish
# but we assign violation marks as not to depend on that knowledge.

# Main Stress: The primary stress in Finnish is on the first
#              syllable. This is an inviolable constraint.

defs['MainStress'] = regex('[B MSS ~$MSS]')


# Clash: No stress on adjacent syllables.
# define Clash SS -> ... {*} || SS B _ ;
defs['Clash'] = regex('SS -> ... {*} || SS B _ ')



# Align-Left: The stressed syllable is initial in the foot.

defs['AlignLeft'] = regex('SV -> ... {*} || .#. ~[?* "(" C*] _ ')


# Foot-Bin: Feet are minimally bimoraic and maximally bisyllabic.
# define FootBin ["(" Light ")" | "(" S ["." S]^>1] -> ... {*} ;
defs['FootBin'] = regex('["(" Light ")" | "(" S ["." S]^>1] -> ... {*} ')


# Lapse: Every unstressed syllable must be adjacent to a stressed
# syllable.
# define Lapse US -> ... {*} || [B US B] _ [B US B];
defs['Lapse'] = regex('US -> ... {*} || [B US B] _ [B US B]')


# Non-Final: The final syllable is not stressed.

defs['NonFinal'] = regex('SS -> ... {*} || _ ~$S .#.')


# Stress-To-Weight: Stressed syllables are heavy.

defs['StressToWeight'] = regex('[SS & Light] -> ... {*} || _ ")"| E')


# License-&#963;: Syllables are parsed into feet.

defs['Parse'] = regex('S -> ... {*} || E _ E')


# All-Ft-Left: Every foot starts at the beginning of a
#              prosodic word.

defs['AllFeetFirst'] = regex('[ "(" -> ... {*} || .#. SB _ .o. "(" -> ... {*}^2 || .#. SB^2 _ .o. "(" -> ... {*}^3 || .#. SB^3 _ .o. "(" -> ... {*}^4 || .#. SB^4 _ .o. "(" -> ... {*}^5 || .#. SB^5 _ .o. "(" -> ... {*}^6 || .#. SB^6 _ .o. "(" -> ... {*}^7 || .#. SB^7 _ .o. "(" -> ... {*}^8 || .#. SB^8 _ ]')
#echo '"(" -> ... {*} || .#. SB _ ' | $2/hfst-regexp2fst -f $1 > a0
#echo '"(" -> ... {*}^2 || .#. SB^2 _ '  | $2/hfst-regexp2fst -f $1 > a1
#echo '"(" -> ... {*}^3 || .#. SB^3 _ '  | $2/hfst-regexp2fst -f $1 > a2
#echo '"(" -> ... {*}^4 || .#. SB^4 _ '  | $2/hfst-regexp2fst -f $1 > a3
#echo '"(" -> ... {*}^5 || .#. SB^5 _ '  | $2/hfst-regexp2fst -f $1 > a4
#echo '"(" -> ... {*}^6 || .#. SB^6 _ '  | $2/hfst-regexp2fst -f $1 > a5
#echo '"(" -> ... {*}^7 || .#. SB^7 _ '  | $2/hfst-regexp2fst -f $1 > a6
#echo '"(" -> ... {*}^8 || .#. SB^8 _ ' | $2/hfst-regexp2fst -f $1 > a7


# Evaluation
# Computing the prosody for FinnWords

# Some constraints can always be satisfied; some constraints are
# violated many times. The limits have been chosen to produce
# a unique winner in all the 25 test cases in FinnWords.

Result = regex('[FinnWords .o. Gen .o. MainStress .o. Clash .O. Viol0 .o. Pardon .o. AlignLeft .O. Viol0 .o. FootBin .O. Viol0 .o. Pardon .o. Lapse .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon .o. NonFinal .O. Viol0 .o. Pardon .o. StressToWeight .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon .o. Parse .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon .o. AllFeetFirst .O. Viol15 .O. Viol14 .O. Viol13 Viol12 .O. Viol11 .O. Viol10 .O. Viol9 .O. Viol8 .O. Viol7 .O. Viol6  .O. Viol5  .O. Viol4  .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon ]')
Result.minimize()
Result.write_to_file('Result')


#echo '[ MainStress .o. Clash .O. Viol0 .o. Pardon .o. AlignLeft .O. Viol0 ]' | $2/hfst-regexp2fst -f $1 > FinnishOTProsody.hfst.hfst






#echo '[FinnWords .o. Gen .o. MainStress .o. Clash .O. Viol0 .o. Pardon .o. AlignLeft .O. Viol0 .o. FootBin .O. Viol0 .o. Pardon .o. Lapse .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon .o. NonFinal .O. Viol0 .o. Pardon .o. StressToWeight .O. Viol3 .O. Viol2 .O. Viol1 .O. Viol0 .o. Pardon .o. Parse .O. Viol3 .O. Viol2 .O. Viol1 ]' | $2/hfst-regexp2fst -f $1 > Result

