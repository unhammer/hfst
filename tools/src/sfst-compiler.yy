%{
/*******************************************************************/
/*                                                                 */
/*  FILE     sfst-compiler.yy                                       */
/*  MODULE   sfst-compiler                                          */
/*  PROGRAM  HFST                                                  */
/*                                                                 */
/*******************************************************************/

#ifdef WINDOWS
#include <io.h>
#endif

#include "SfstCompiler.h"
#include "HfstTransducer.h"

extern char * folder;
extern char * FileName;

extern int  sfstlineno;
extern char *sfsttext;
int sfstlex( void );

using namespace hfst;
using std::cerr;

void sfsterror(char *text)

{
  cerr << "\n" << FileName << ":" << sfstlineno << ": " << text << " at: ";
  cerr << sfsttext << "\naborted.\n";
  exit(1);
}

void warn(char *text)

{
  cerr << "\n" << FileName << ":" << sfstlineno << ": warning: " << text << "!\n";
}

void warn2(const char *text, char *text2)

{
  cerr << "\n" << FileName << ":" << sfstlineno << ": warning: " << text << ": ";
  cerr << text2 << "\n";
}

extern int Switch;
extern SfstCompiler * compiler;
//HfstTransducer * Result;

bool DEBUG = false;

%}

%name-prefix="sfst"

%union {
  int        number;
  hfst::Twol_Type  type;
  hfst::Repl_Type  rtype;
  char       *name;
  char       *value;
  unsigned char uchar;
  unsigned int  longchar;
  hfst::Character  character;
  hfst::HfstTransducer   *expression;
  hfst::Range      *range;
  hfst::Ranges     *ranges;
  hfst::Contexts   *contexts;
}

%token <number> NEWLINE ALPHA COMPOSE PRINT POS INSERT SUBSTITUTE SWITCH
%token <type>   ARROW
%token <rtype>  REPLACE
%token <name>   SYMBOL VAR SVAR RVAR RSVAR
%token <value>  STRING STRING2 UTF8CHAR
%token <uchar>  CHARACTER

%type  <uchar>      SCHAR
%type  <longchar>   LCHAR
%type  <character>  CODE
%type  <expression> RE
%type  <range>      RANGE VALUE VALUES
%type  <ranges>     RANGES
%type  <contexts>   CONTEXT CONTEXT2 CONTEXTS CONTEXTS2

%left PRINT INSERT SUBSTITUTE
%left ARROW REPLACE
%left COMPOSE
%left '|'
%left '-'
%left '&'
%left SEQ
%left '!' '^' '_'
%left '*' '+'
%%

ALL:        ASSIGNMENTS RE NEWLINES { compiler->set_result(compiler->result($2, Switch)); }
          ;

ASSIGNMENTS: ASSIGNMENTS ASSIGNMENT {}
          | ASSIGNMENTS NEWLINE     {}
          | /* nothing */           {}
          ;

ASSIGNMENT: VAR '=' RE              { if (DEBUG) { printf("defining transducer variable \"%s\"..\n", $1); }; if (compiler->def_var($1,$3)) warn2("assignment of empty transducer to",$1); if(DEBUG) printf("done\n"); }
          | RVAR '=' RE             { if (DEBUG) { printf("defining agreement transducer variable \"%s\"..\n", $1); }; if (compiler->def_rvar($1,$3)) warn2("assignment of empty transducer to",$1); }
          | SVAR '=' VALUES         { if (DEBUG) { printf("defining range variable \"%s\"..\n", $1); }; if (compiler->def_svar($1,$3)) warn2("assignment of empty symbol range to",$1); }
          | RSVAR '=' VALUES        { if (DEBUG) { printf("defining agreement range variable \"%s\"..\n", $1); }; if (compiler->def_svar($1,$3)) warn2("assignment of empty symbol range to",$1); }
          | RE PRINT STRING         { compiler->write_to_file($1, folder, $3); }
          | ALPHA RE                { if (DEBUG) { printf("defining alphabet..\n"); }; compiler->def_alphabet($2); delete $2; }
          ;

RE:         RE ARROW CONTEXTS2      { $$ = compiler->restriction($1,$2,$3,0); }
	  | RE '^' ARROW CONTEXTS2  { $$ = compiler->restriction($1,$3,$4,1); }
	  | RE '_' ARROW CONTEXTS2  { $$ = compiler->restriction($1,$3,$4,-1); }
          | RE REPLACE CONTEXT2     { $1 = compiler->explode($1); $1->minimize(); $$ = compiler->replace_in_context($1, $2, $3, false); }
          | RE REPLACE '?' CONTEXT2 { $1 = compiler->explode($1); $1->minimize(); $$ = compiler->replace_in_context($1, $2, $4, true); }
          | RE REPLACE '(' ')'      { $1 = compiler->explode($1); $1->minimize(); $$ = compiler->replace($1, $2, false); }
          | RE REPLACE '?' '(' ')'  { $1 = compiler->explode($1); $1->minimize(); $$ = compiler->replace($1, $2, true); }
          | RE RANGE ARROW RANGE RE { $$ = compiler->make_rule($1,$2,$3,$4,$5, compiler->compiler_type); }
          | RE RANGE ARROW RANGE    { $$ = compiler->make_rule($1,$2,$3,$4,NULL, compiler->compiler_type); }
          | RANGE ARROW RANGE RE    { $$ = compiler->make_rule(NULL,$1,$2,$3,$4, compiler->compiler_type); }
          | RANGE ARROW RANGE       { $$ = compiler->make_rule(NULL,$1,$2,$3,NULL, compiler->compiler_type); }
          | RE COMPOSE RE    { $1->compose(*$3); delete $3; $$ = $1; }
          | '{' RANGES '}' ':' '{' RANGES '}' { $$ = compiler->make_mapping($2,$6,compiler->compiler_type); }
          | RANGE ':' '{' RANGES '}' { $$ = compiler->make_mapping(compiler->add_range($1,NULL),$4,compiler->compiler_type); }
          | '{' RANGES '}' ':' RANGE { $$ = compiler->make_mapping($2,compiler->add_range($5,NULL),compiler->compiler_type); }
          | RE INSERT CODE ':' CODE  { $$ = compiler->insert_freely($1,$3,$5); }
          | RE INSERT CODE           { $$ = compiler->insert_freely($1,$3,$3); }
	  | RE SUBSTITUTE CODE ':' CODE  { $$ = compiler->substitute($1,$3,$5); }
	  | RE SUBSTITUTE CODE ':' CODE ':' CODE ':' CODE { $$ = compiler->substitute($1,$3,$5,$7,$9); }
	  | RE SUBSTITUTE CODE ':' CODE '(' RE ')' { $$ = compiler->substitute($1,$3,$5,$7); }
          | RANGE ':' RANGE  { $$ = compiler->new_transducer($1,$3,compiler->compiler_type); }
          | RANGE            { $$ = compiler->new_transducer($1,$1,compiler->compiler_type); }
          | VAR              { if (DEBUG) { printf("calling transducer variable \"%s\"\n", $1); }; $$ = compiler->var_value($1); }
          | RVAR             { if (DEBUG) { printf("calling agreement transducer variable \"%s\"\n", $1); }; $$ = compiler->rvar_value($1,compiler->compiler_type); }
          | RE '*'           { $1->repeat_star(); $$ = $1; }
          | RE '+'           { $1->repeat_plus(); $$ = $1; }
          | RE '?'           { $1->optionalize(); $$ = $1; }
          | RE RE %prec SEQ  { $1->concatenate(*$2); delete $2; $$ = $1; }
          | '!' RE           { $$ = compiler->negation($2); }
          | SWITCH RE        { $2->invert(); $$ = $2; }
          | '^' RE           { $2->output_project(); $$ = $2; }
          | '_' RE           { $2->input_project(); $$ = $2; }
          | RE '&' RE        { $1->intersect(*$3); delete $3; $$ = $1; }
          | RE '-' RE        { $1->subtract(*$3); delete $3; $$ = $1; }
          | RE '|' RE        { $1->disjunct(*$3); delete $3; $$ = $1; }
          | '(' RE ')'       { $$ = $2; }
          | STRING           { $$ = compiler->read_words(folder, $1, compiler->compiler_type); }
          | STRING2          { try { $$ = compiler->read_transducer(folder, $1, compiler->compiler_type); } catch (HfstException e) { printf("\nAn error happened when reading file \"%s\"\n", $1); exit(1); } }
          ;

RANGES:     RANGE RANGES     { $$ = compiler->add_range($1,$2); }
          |                  { $$ = NULL; }
          ;

RANGE:      '[' VALUES ']'   { $$=$2; }
          | '[' '^' VALUES ']' { $$=compiler->complement_range($3); }
          | '[' RSVAR ']'    { if (DEBUG) { printf("calling agreement range variable \"%s\"\n", $2); }; $$=compiler->rsvar_value($2); }
          | '.'              { $$=NULL; }
          | CODE             { $$=compiler->add_value($1,NULL); }
          ;

CONTEXTS2:  CONTEXTS               { $$ = $1; }
          | '(' CONTEXTS ')'       { $$ = $2; }
          ;

CONTEXTS:   CONTEXT ',' CONTEXTS   { $$ = compiler->add_context($1,$3); }
          | CONTEXT                { $$ = $1; }
          ;

CONTEXT2:   CONTEXT                { $$ = $1; }
          | '(' CONTEXT ')'        { $$ = $2; }
          ;

CONTEXT :   RE POS RE              { $$ = compiler->make_context($1, $3); }
          |    POS RE              { $$ = compiler->make_context(NULL, $2); }
          | RE POS                 { $$ = compiler->make_context($1, NULL); }
          ;

VALUES:     VALUE VALUES           { $$=compiler->append_values($1,$2); }
          | VALUE                  { $$ = $1; }
          ;

VALUE:      LCHAR '-' LCHAR	   { $$=compiler->add_values($1,$3,NULL); }
          | SVAR                   { if (DEBUG) { printf("calling range variable \"%s\"", $1); }; $$=compiler->svar_value($1); }
          | LCHAR  	           { $$=compiler->add_value(compiler->character_code($1),NULL); }
          | CODE		   { $$=compiler->add_value($1,NULL); }
	  | SCHAR		   { $$=compiler->add_value($1,NULL); }
          ;

LCHAR:      CHARACTER	{ $$=$1; }
          | UTF8CHAR	{ $$=compiler->utf8toint($1); free($1); }
	  | SCHAR       { $$=$1; }
          ;

CODE:       CHARACTER	{ $$=compiler->character_code($1); }
          | UTF8CHAR	{ $$=compiler->symbol_code($1); }
          | SYMBOL	{ $$=compiler->symbol_code($1); }
          ;

SCHAR:      '.'		{ $$=(unsigned char)compiler->character_code('.'); }
          | '!'		{ $$=(unsigned char)compiler->character_code('!'); }
          | '?'		{ $$=(unsigned char)compiler->character_code('?'); }
          | '{'		{ $$=(unsigned char)compiler->character_code('{'); }
          | '}'		{ $$=(unsigned char)compiler->character_code('}'); }
          | ')'		{ $$=(unsigned char)compiler->character_code(')'); }
          | '('		{ $$=(unsigned char)compiler->character_code('('); }
          | '&'		{ $$=(unsigned char)compiler->character_code('&'); }
          | '|'		{ $$=(unsigned char)compiler->character_code('|'); }
          | '*'		{ $$=(unsigned char)compiler->character_code('*'); }
          | '+'		{ $$=(unsigned char)compiler->character_code('+'); }
          | ':'		{ $$=(unsigned char)compiler->character_code(':'); }
          | ','		{ $$=(unsigned char)compiler->character_code(','); }
          | '='		{ $$=(unsigned char)compiler->character_code('='); }
          | '_'		{ $$=(unsigned char)compiler->character_code('_'); }
          | '^'		{ $$=(unsigned char)compiler->character_code('^'); }
          | '-'		{ $$=(unsigned char)compiler->character_code('-'); }
          ;

NEWLINES:   NEWLINE NEWLINES     {}
          | /* nothing */        {}
          ;

%%
