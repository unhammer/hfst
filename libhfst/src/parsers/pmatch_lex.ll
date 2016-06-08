%option 8Bit batch yylineno noyywrap nounput prefix="pmatch"

%{
// Copyright (c) 2016 University of Helsinki                          
//                                                                    
// This library is free software; you can redistribute it and/or      
// modify it under the terms of the GNU Lesser General Public         
// License as published by the Free Software Foundation; either       
// version 3 of the License, or (at your option) any later version.
// See the file COPYING included with this distribution for more      
// information.

#include <string.h>

#include "HfstTransducer.h"
#include "HfstInputStream.h"
#include "HfstXeroxRules.h"
#include "pmatch_utils.h"

#ifdef YACC_USE_PARSER_H_EXTENSION
  #include "pmatch_parse.h"
#else
  #include "pmatch_parse.hh"
#endif

#undef YY_INPUT
#define YY_INPUT(buf, retval, maxlen)   (retval = hfst::pmatch::getinput(buf, maxlen))

extern
int pmatcherror(char *text);

%}

/* c.f. Unicode Standard 5.1 D92 Table 3-7 */
U1 [\x20-\x7e]
U2 [\xc2-\xdf][\x80-\xbf]
U31 \xe0[\xa0-\xbf][\x80-\xbf]
U32 [\xe1-\xec][\x80-\xbf][\x80-\xbf]
U33 \xed[\x80-\x9f][\x80-\xbf]
U34 [\xee-\xef][\x80-\xbf][\x80-\xbf]
U41 \xf0[\x90-\xbf][\x80-\xbf][\x80-\xbf]
U42 [\xf1-\xf3][\x80-\xbf][\x80-\xbf][\x80-\xbf]
U43 \xf4[\x80-\x8f][\x80-\xbf][\x80-\xbf]
/* non US-ASCII */
U8H {U43}|{U42}|{U41}|{U34}|{U33}|{U32}|{U31}|{U2}
/* any UTF-8 */
U8C {U8H}|{U1}
/* Escaped */
EC "%"{U8C}

/* any ASCII */
A7 [\x00-\x7e]
/* special meaning in pmatch */
A7RESTRICTED [- |<>%^:;@0~\\&?$+*/_(){}\]\[-]
/* non-restricted ASCII */
A7UNRESTRICTED [\x21-\x7e]{-}[- |<>%^:;,@~\\&?$+*/(){}\]\[]

WEIGHT [0-9]+(\.[0-9]+)?

/* token character */
NAME_CH {A7UNRESTRICTED}|{U8H}|{EC}
ZERO "0"
UINTEGER ([1-9][0-9]*)|{ZERO}
INTEGER (-?[1-9][0-9]*)|{ZERO}
WSP [\t ]
LWSP [\t\r\n ]

HEXCHAR [0-9]|[a-f]
UNICODE_ESCAPE ("\\u"{HEXCHAR}{HEXCHAR}{HEXCHAR}{HEXCHAR})|("\\U00"{HEXCHAR}{HEXCHAR}{HEXCHAR}{HEXCHAR}{HEXCHAR}{HEXCHAR})
%%

[Dd]"efine" { return DEFINE; }
"DefFun" { return DEFINE; }
"regex" { return REGEX; }
"set" { return SET_VARIABLE; }
"list" { return DEFINED_LIST; }
"Lit(" { return LIT_LEFT; }
"Ins(" { return INS_LEFT; }
"EndTag(" { return ENDTAG_LEFT; }
"Cap(" { return CAP_LEFT; }
"OptCap(" { return OPTCAP_LEFT; }
"DownCase(" { return TOLOWER_LEFT; }
"UpCase(" { return TOUPPER_LEFT; }
"OptUpCase(" { return OPT_TOUPPER_LEFT; }
"OptDownCase(" { return OPT_TOLOWER_LEFT; }
"AnyCase(" { return ANY_CASE_LEFT; }
"Explode(" { return EXPLODE_LEFT; }
"Implode(" { return IMPLODE_LEFT; }
"LC(" { return LC_LEFT; }
"RC(" { return RC_LEFT; }
"NLC(" { return NLC_LEFT; }
"NRC(" { return NRC_LEFT; }
"OR(" { return OR_LEFT; }
"AND(" { return AND_LEFT; }
".t(" { return TAG_LEFT; }
"Lst(" { return LST_LEFT; }
"Exc(" { return EXC_LEFT; }
"Interpolate(" { return INTERPOLATE_LEFT; }
"Sigma(" { return SIGMA_LEFT; }
"Counter(" { return COUNTER_LEFT; }
[Dd]"efine(" { return DEFINE_LEFT; }
"DefIns" { return DEFINS; }

"Alpha" { return ALPHA; }
"UppercaseAlpha" { return UPPERALPHA; }
"LowercaseAlpha" { return LOWERALPHA; }
"Num" { return NUM; }
"Punct" { return PUNCT; }
"Whitespace" { return WHITESPACE; }

"count-patterns" {
    pmatchlval.label = strcpy((char *) malloc(strlen("count-patterns") + 1), "count-patterns");
    return VARIABLE_NAME;
}
"delete-patterns" {
    pmatchlval.label = strcpy((char *) malloc(strlen("delete-patterns") + 1), "delete-patterns");
    return VARIABLE_NAME;
}
"extract-patterns" {
    pmatchlval.label = strcpy((char *) malloc(strlen("extract-patterns") + 1), "extract-patterns");
    return VARIABLE_NAME;
}
"locate-patterns" {
    pmatchlval.label = strcpy((char *) malloc(strlen("locate-patterns") + 1), "locate-patterns");
    return VARIABLE_NAME;
}
"mark-patterns" {
    pmatchlval.label = strcpy((char *) malloc(strlen("mark-patterns") + 1), "mark-patterns");
    return VARIABLE_NAME;
}
"need-separators" {
    pmatchlval.label = strcpy((char *) malloc(strlen("need-separators") + 1), "need-separators");
    return VARIABLE_NAME;
}
"max-context-length" {
    pmatchlval.label = strcpy((char *) malloc(strlen("max-context_length") + 1), "max-context-length");
    return VARIABLE_NAME;
}
"max-recursion" {
    pmatchlval.label = strcpy((char *) malloc(strlen("max-recursion") + 1), "max-recursion");
    return VARIABLE_NAME;
}

"~"   { return COMPLEMENT; }
"\\"  { return TERM_COMPLEMENT; }
"&"   { return INTERSECTION; }
"-"   { return MINUS; }

"$."  { return CONTAINMENT_ONCE; }
"$?"  { return CONTAINMENT_OPT; }
"$"   { return CONTAINMENT; }

"+" { return PLUS; }
"*" { return STAR; }

"./." { return IGNORE_INTERNALLY; }
"/"   { return IGNORING; }

"|" { return UNION; }

"\"\"" { return EPSILON_TOKEN; }
"[]" { return EPSILON_TOKEN; }
"0" { return EPSILON_TOKEN; }
"?" { return ANY_TOKEN; }
"#"|".#." { return BOUNDARY_MARKER; }

"<>" { return SHUFFLE; }
"<" { return BEFORE; }
">" { return AFTER; }

".o." { return COMPOSITION; }
".O." { return LENIENT_COMPOSITION; }
".m>." { return MERGE_RIGHT_ARROW; }
".<m." { return MERGE_LEFT_ARROW; }
".x." { return CROSS_PRODUCT; }
".P." { return UPPER_PRIORITY_UNION; }
".p." { return LOWER_PRIORITY_UNION; }
".-u." { return UPPER_MINUS; }
".-l." { return LOWER_MINUS; }
"`" { return SUBSTITUTE_LEFT; }

"\\<=" { return LEFT_RESTRICTION; } /* Not implemented */
"<=>" { return LEFT_RIGHT_ARROW; }
"<=" { return LEFT_ARROW; }
"=>" { return RIGHT_ARROW; }

"->" { return REPLACE_RIGHT; }
"(->)" { return OPTIONAL_REPLACE_RIGHT; }
"<-" { return REPLACE_LEFT; }
"(<-)" { return OPTIONAL_REPLACE_LEFT; }
"<->" { return REPLACE_LEFT_RIGHT; }
"(<->)" { return OPTIONAL_REPLACE_LEFT_RIGHT; }
"@->" { return LTR_LONGEST_MATCH; }
"@>" { return LTR_SHORTEST_MATCH; }
"->@" { return RTL_LONGEST_MATCH; }
">@" { return RTL_SHORTEST_MATCH; }

"||" { return REPLACE_CONTEXT_UU; }
"//" { return REPLACE_CONTEXT_LU; }
"\\\\" { return REPLACE_CONTEXT_UL; }
"\\//" { return REPLACE_CONTEXT_LL; }
"_"+ { return CENTER_MARKER; }
"..."+ { return MARKUP_MARKER; }

"\\\\\\" { return LEFT_QUOTIENT; }

"^"{UINTEGER}","{UINTEGER} {
    pmatchlval.values = hfst::pmatch::get_n_to_k(pmatchtext);
    return CATENATE_N_TO_K;
}

"^{"{UINTEGER}","{UINTEGER}"}" {
    pmatchlval.values = hfst::pmatch::get_n_to_k(pmatchtext);
    return CATENATE_N_TO_K;
}

"^>"{UINTEGER} {
    pmatchlval.value = strtol(pmatchtext + 2, 0, 10);
    return CATENATE_N_PLUS;
}

"^<"{UINTEGER} {
    pmatchlval.value = strtol(pmatchtext + 2, 0, 10);
    return CATENATE_N_MINUS;
}

"^"{UINTEGER}                  {
    pmatchlval.value = strtol(pmatchtext + 1, 0, 10);
    return CATENATE_N;
}

".r"  { return REVERSE; }
".i"  { return INVERT; }
".u"  { return UPPER_PROJECT; }
".l"  { return LOWER_PROJECT; }

"@bin\""[^""]+"\""|"@\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_BIN;
}

"@txt\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_TEXT;
}

"@stxt\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_SPACED;
}

"@pl\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_PROLOG;
}

"@lexc\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_LEXC;
}

"@re\""[^""]+"\"" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '"');
    return READ_RE;
}

"\""(({UNICODE_ESCAPE}|{U8C})"-"({UNICODE_ESCAPE}|{U8C}))+"\"" {
    pmatchlval.pmatchObject = hfst::pmatch::parse_range(pmatchtext);
    return CHARACTER_RANGE;
}

{NAME_CH}+"(" {
    char * label = (char *) malloc(strlen(pmatchtext));
    strncpy(label, pmatchtext, strlen(pmatchtext));
    label[strlen(pmatchtext) - 1] = '\0';
    pmatchlval.label = hfst::pmatch::strip_percents(label);
    free(label);
    return SYMBOL_WITH_LEFT_PAREN;
}

"[." { return LEFT_BRACKET_DOTTED; }
".]" { return RIGHT_BRACKET_DOTTED; }
"[" { return LEFT_BRACKET; }
"]" { return RIGHT_BRACKET; }
"(" { return LEFT_PARENTHESIS; }
")" { return RIGHT_PARENTHESIS; }

{LWSP}":"{LWSP} { return PAIR_SEPARATOR_SOLE; }
^":"$ { return PAIR_SEPARATOR_SOLE; }
{LWSP}":" { return PAIR_SEPARATOR_WO_LEFT; }
":"{LWSP} { return PAIR_SEPARATOR_WO_RIGHT; }
":" { return PAIR_SEPARATOR; }

"::"{WEIGHT} {
    pmatchlval.weight = hfst::pmatch::get_weight(pmatchtext + 2);
    return WEIGHT;
}

"{"([^}]|"\\}")+"}" {
    pmatchlval.label = hfst::pmatch::get_escaped_delimited(pmatchtext, '{', '}');
    return CURLY_LITERAL;
}

"\""([^"\""]|"\\\"")+"\"" {
    pmatchlval.label = hfst::pmatch::parse_quoted(pmatchtext);
    return QUOTED_LITERAL;
}

{NAME_CH}+ {
    pmatchlval.label = hfst::pmatch::strip_percents(pmatchtext);
    return SYMBOL;
}

",," { return COMMACOMMA; }
"," { return COMMA; }

";"{WSP}*{WEIGHT} {
    pmatchlval.weight = hfst::pmatch::get_weight(pmatchtext + 2);
    return END_OF_WEIGHTED_EXPRESSION;
}

";" {
    pmatchlval.weight = 0.0;
    return END_OF_WEIGHTED_EXPRESSION;
}

{LWSP}* { /* ignorable whitespace */ }

("!")[^\n]*$ { /* ignore comments */ }

. { 
    return LEXER_ERROR;
}

%%
