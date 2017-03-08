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

#include "HfstTwolcDefs.h"
#include "io_src/InputReader.h"
#include "commandline_src/CommandLine.h"
#include "grammar_defs.h"

extern int htwolcpre2parse();
extern InputReader pre2_input_reader;

// non_alphabet_symbol_queue is used to store the grammar symbols which are
// not located in the Alphabet section of the grammar.
HandyDeque<std::string> non_alphabet_symbol_queue;

// alphabet_symbol_queue is used to store the symbols in the Alphabet section
// of the grammar.
HandyDeque<std::string> alphabet_symbol_queue;

// alphabet_symbol_queue is used to store the symbols in the Alphabet section
// of the grammar after it has been completed with all symbol pairs in the
// grammar.
HandyDeque<std::string> total_alphabet_symbol_queue;

void insert_alphabet_pairs(const HandyDeque<std::string> &symbol_queue,
			   HandySet<SymbolPair> &symbol_pair_set)
{
  for (HandyDeque<std::string>::const_iterator it = symbol_queue.begin();
       it != symbol_queue.end();
       ++it)
    {
      //If we found a symbol pair, we insert it into symbol_pair_set.
      if ((*it == "__HFST_TWOLC_0" ||
	   *it == "__HFST_TWOLC_.#." ||
	   *it == "__HFST_TWOLC_#" ||
	   *it == "__HFST_TWOLC_SPACE" ||
	   *it == "__HFST_TWOLC_TAB" ||
           it->find("__HFST_TWOLC_") == std::string::npos)
	  &&
	  *(it+1) == "__HFST_TWOLC_:"
	  &&
	  (*(it+2) == "__HFST_TWOLC_0" ||
	   *(it+2) == "__HFST_TWOLC_.#." ||
	   *(it+2) == "__HFST_TWOLC_#" ||
	   *(it+2) == "__HFST_TWOLC_SPACE" ||
	   *(it+2) == "__HFST_TWOLC_TAB" ||
           (it+2)->find("__HFST_TWOLC_") == std::string::npos))
	{
	  std::string input_symbol = *it == "__HFST_TWOLC_#" ? "#" : *it;
	  ++(++it);
	  std::string output_symbol = *it == "__HFST_TWOLC_#" ? "#" : *it;
	  symbol_pair_set.insert(SymbolPair(input_symbol,output_symbol));
	}
    }
  symbol_pair_set.insert(SymbolPair("__HFST_TWOLC_.#.","__HFST_TWOLC_.#."));
}

// Add all pairs in the grammar, which are missing from the Alphabet section,
// into the Alphabet section.
void complete_alphabet(void)
{
  HandySet<SymbolPair> symbol_pair_set;
  insert_alphabet_pairs(alphabet_symbol_queue,symbol_pair_set);
  insert_alphabet_pairs(non_alphabet_symbol_queue,symbol_pair_set);

  total_alphabet_symbol_queue.push_back("__HFST_TWOLC_Alphabet");
  for(HandySet<SymbolPair>::const_iterator it = symbol_pair_set.begin();
      it != symbol_pair_set.end();
      ++it)
    {
      total_alphabet_symbol_queue.push_back(it->first);
      total_alphabet_symbol_queue.push_back("__HFST_TWOLC_:");
      total_alphabet_symbol_queue.push_back(it->second);
    }
}

int main(int argc, char * argv[])
{
#ifdef WINDOWS
  _setmode(0, _O_BINARY);
  _setmode(1, _O_BINARY);
#endif

  CommandLine command_line(argc,argv);
  if (command_line.help || command_line.usage || command_line.version)
    { exit(0); }
  //yydebug = 1;
  pre2_input_reader.set_input(std::cin);
  int exit_code = htwolcpre2parse();
  complete_alphabet();
  std::cout << total_alphabet_symbol_queue << " ";
  std::cout << non_alphabet_symbol_queue;
  return exit_code;
}
