## @package hfst.xerox_rules
# Xerox-type two-level-rules.

## ...
REPL_UP = _libhfst.REPL_UP
## ...
REPL_DOWN = _libhfst.REPL_DOWN
## ...
REPL_LEFT = _libhfst.REPL_LEFT
## ...
REPL_RIGHT = _libhfst.REPL_RIGHT
        
## A rule that contains mapping and context and replace type (if any).
# If rule is A -> B || L _ R , than mapping is cross product of transducers A and B,
# context is pair of transducers L and R, and replType is enum REPL_UP.
class Rule:
        ## ...
        # @param mapping HfstTransducerPairVector
        def __init__(self, mapping):
                pass
        ## ...
        # @param mapping HfstTransducerPairVector
        # @param context HfstTransducerPairVector
        # @param type ReplType
        def __init__(self, mapping, context, type):
                pass
        ## Copy
        # @param rule Rule
        def __init__(self, rule):
                pass
        ## Default constructor needed for SWIG
        def __init__(self):
                pass
        ## ...
        # @return HfstTransducerPairVector 
        def get_mapping(self):
                pass
        ## ...
        # @return HfstTransducerPairVector
        def get_context():
                pass
        ## ...
        # @return ReplaceType
        def get_replType():
                pass
        ## ...           
        def encodeFlags():
                pass             
        # friend std::ostream& operator<<(std::ostream &out, const Rule &r);

## replace up, left, right, down
# @param rule Rule, HfstRuleVector
# @param optional Bool
def replace(rule, optional):
        pass
## replace up, left, right, down
# @param rule Rule, HfstRuleVector
# @param optional Bool
def xerox_replace_left(rule, optional):
        pass
## left to right
# @param rule Rule, HfstRuleVector
def replace_leftmost_longest_match(rule):
        pass
## right to left
# @param rule Rule, HfstRuleVector
def replace_rightmost_longest_match(rule):
        pass
## ...
# @param rule Rule, HfstRuleVector
def replace_leftmost_shortest_match(rule):
        pass
## ...
# @param rule Rule, HfstRuleVector
def replace_rightmost_shortest_match(rule):
        pass
## replace up, left, right, down
# @param rule Rule, HfstRuleVector
# @param optional Bool
def replace_epenthesis(rule, optional):
        pass
## Restriction function "=>"
# @param automaton HfstTransducer
# @param context HfstTransducerPairVector
def xerox_restriction(automaton, context):
        pass
## ...
# @param left HfstTransducer
# @param right HfstTransducer
def before(left, right):
        pass
## ...
# @param left HfstTransducer
# @param right HfstTransducer
def after(left, right):
        pass
