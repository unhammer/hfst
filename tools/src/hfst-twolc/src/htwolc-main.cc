//   This program is free software: you can redistribute it and/or modify
//   it under the terms of the GNU General Public License as published by
//   the Free Software Foundation, version 3 of the Licence.
//
//   This program is distributed in the hope that it will be useful,
//   but WITHOUT ANY WARRANTY; without even the implied warranty of
//   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//   GNU General Public License for more details.
//
//   You should have received a copy of the GNU General Public License
//   along with this program.  If not, see <http://www.gnu.org/licenses/>.

#include "commandline_src/CommandLine.h"
#include "HfstTwolcDefs.h"
#include "io_src/InputReader.h"
#include "grammar_defs.h"
#include "rule_src/TwolCGrammar.h"
#include "rule_src/OtherSymbolTransducer.h"

int htwolcpre1parse();
void htwolcpre1_set_input(std::istream & istr);
void htwolcpre1_set_output(std::ostream & ostr);

int htwolcpre2parse();
void htwolcpre2_set_input(std::istream & istr);
void htwolcpre2_complete_alphabet(void);
const HandyDeque<std::string> & htwolcpre2_get_total_alphabet_symbol_queue();
const HandyDeque<std::string> & htwolcpre2_get_non_alphabet_symbol_queue();

int htwolcpre3parse();
void htwolcpre3_set_input(std::istream & istr);
void htwolcpre3_set_grammar(TwolCGrammar * grammar);
TwolCGrammar * htwolcpre3_get_grammar();
void htwolcpre3_set_silent(bool val);
void htwolcpre3_set_verbose(bool val);

bool silent=false;
bool verbose=false;

void message(const std::string &m);

int main(int argc, char * argv[])
{
#ifdef WINDOWS
  _setmode(0, _O_BINARY);
  _setmode(1, _O_BINARY);
#endif

  CommandLine command_line(argc,argv);

  if (command_line.help || command_line.version)
    {
      if (command_line.version)
	{ command_line.print_version(); }
      if (command_line.help)
	{ command_line.print_help(); }
      exit(0);
    }
  if (command_line.usage)
    {
      command_line.print_usage();
      exit(0);
    }
  if (! command_line.be_quiet)
    {
      if (! command_line.has_input_file)
	{ std::cerr << "Reading input from STDIN." << std::endl; }
      else
	{ std::cerr << "Reading input from " << command_line.input_file_name
		    << "." << std::endl; }
      if (! command_line.has_output_file)
	{ std::cerr << "Writing output to STDOUT." << std::endl; }
      else
	{ std::cerr << "Writing output to " << command_line.output_file_name
		    << "." << std::endl; }
    }
  if (command_line.be_verbose)
    { std::cerr << "Verbose mode." << std::endl; }

  htwolcpre1_set_input(command_line.set_input_file());

  // Test that the output file is okay.
  (void)command_line.set_output_file();
  std::ostringstream oss1;
  htwolcpre1_set_output(oss1);
  if (htwolcpre1parse() != 0)
    {
      exit(1);
    }

  std::istringstream iss1(oss1.str());
  htwolcpre2_set_input(iss1);
  if (htwolcpre2parse() != 0)
    {
      exit(1);
    }
  htwolcpre2_complete_alphabet();
  
  std::ostringstream oss2;
  oss2 << htwolcpre2_get_total_alphabet_symbol_queue() << " ";
  oss2 << htwolcpre2_get_non_alphabet_symbol_queue();

#ifdef DEBUG_TWOLC_3_GRAMMAR
  htwolcpre3debug = 1;
#endif

  try
    {
      std::istringstream iss2(oss2.str());
      htwolcpre3_set_input(iss2);
      
      OtherSymbolTransducer::set_transducer_type(command_line.format);
      silent = command_line.be_quiet;
      htwolcpre3_set_silent(silent);
      verbose = command_line.be_verbose;
      htwolcpre3_set_verbose(verbose);
      
      TwolCGrammar twolc_grammar(command_line.be_quiet,
				 command_line.be_verbose,
				 command_line.resolve_left_conflicts,
				 command_line.resolve_right_conflicts);
      htwolcpre3_set_grammar(&twolc_grammar);
      int exit_code = htwolcpre3parse();
      if (exit_code != 0)
    { exit(exit_code); }
      
      message("Compiling and storing rules.");
      if (! command_line.has_output_file)
    {
      HfstOutputStream stdout_(command_line.format);
      htwolcpre3_get_grammar()->compile_and_store(stdout_);
    }
      else
    {
      HfstOutputStream out
        (command_line.output_file_name,command_line.format);
      htwolcpre3_get_grammar()->compile_and_store(out);
    }
      exit(0);
    }
  catch (const HfstException e)
    {
      std::cerr << "This is an hfst interface bug:" << std::endl
        << e() << std::endl;
      exit(1);
    }
  catch (const char * s)
    {
      std::cerr << "This is an a bug probably from sfst:" << std::endl
        << s << std::endl;
      exit(1);
    }
}


