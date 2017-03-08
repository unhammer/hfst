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

#include "io_src/InputReader.h"
#include "rule_src/TwolCGrammar.h"
#include "rule_src/OtherSymbolTransducer.h"
#include "commandline_src/CommandLine.h"

extern int htwolcpre3parse();
extern InputReader pre3_input_reader;
extern TwolCGrammar * grammar;
bool silent=false;
bool verbose=false;

void message(const std::string &m);

int main(int argc, char * argv[])
{
#ifdef WINDOWS
  _setmode(0, _O_BINARY);
  _setmode(1, _O_BINARY);
#endif

#ifdef DEBUG_TWOLC_3_GRAMMAR
  htwolcpre3debug = 1;
#endif

  try
    {
      CommandLine command_line(argc,argv);
      if (command_line.help || command_line.usage || command_line.version)
    { exit(0); }
      if (command_line.has_debug_file)
    { pre3_input_reader.set_input(command_line.set_input_file()); }
      else
    { pre3_input_reader.set_input(std::cin); }
      
      OtherSymbolTransducer::set_transducer_type(command_line.format);
      silent = command_line.be_quiet;
      verbose = command_line.be_verbose;
      
      TwolCGrammar twolc_grammar(command_line.be_quiet,
				 command_line.be_verbose,
				 command_line.resolve_left_conflicts,
				 command_line.resolve_right_conflicts);
      grammar = &twolc_grammar;
      int exit_code = htwolcpre3parse();
      if (exit_code != 0)
    { exit(exit_code); }
      
      message("Compiling and storing rules.");
      if (! command_line.has_output_file)
    {
      HfstOutputStream stdout_(command_line.format);
      grammar->compile_and_store(stdout_);
    }
      else
    {
      HfstOutputStream out
        (command_line.output_file_name,command_line.format);
      grammar->compile_and_store(out);
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


