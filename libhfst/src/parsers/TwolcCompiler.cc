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
#include "TwolcCompiler.h"

namespace hfst {
  namespace twolcpre1 {
    int parse();
    void set_input(std::istream & istr);
    void set_output(std::ostream & ostr);
    void set_warning_stream(std::ostream & ostr);
    void set_error_stream(std::ostream & ostr);
  }
}

namespace hfst {
  namespace twolcpre2 {
    int parse();
    void set_input(std::istream & istr);
    void complete_alphabet(void);
    const HandyDeque<std::string> & get_total_alphabet_symbol_queue();
    const HandyDeque<std::string> & get_non_alphabet_symbol_queue();
    void set_warning_stream(std::ostream & ostr);
    void set_error_stream(std::ostream & ostr);
  }
}

namespace hfst {
  namespace twolcpre3 {
    int parse();
    void set_input(std::istream & istr);
    void set_grammar(TwolCGrammar * grammar);
    TwolCGrammar * get_grammar();
    void set_silent(bool val);
    void set_verbose(bool val);
    void message(const std::string &m);
    void set_warning_stream(std::ostream & ostr);
    void set_error_stream(std::ostream & ostr);
  }
}

namespace hfst {

  TwolcCompiler::TwolcCompiler(const CommandLine & cl, std::ostream & warn, std::ostream & error):
    command_line(cl), warning_stream(warn), error_stream(error) {};

  void TwolcCompiler::compile()
  {
    hfst::twolcpre1::set_input(command_line.set_input_file());
    std::ostringstream oss1;
    hfst::twolcpre1::set_output(oss1);
    hfst::twolcpre1::set_warning_stream(this->warning_stream);
    hfst::twolcpre1::set_error_stream(this->error_stream);
    if (hfst::twolcpre1::parse() != 0)
      {
	HFST_THROW(HfstException);
      }

    std::istringstream iss1(oss1.str());
    hfst::twolcpre2::set_input(iss1);
    hfst::twolcpre2::set_warning_stream(this->warning_stream);
    hfst::twolcpre2::set_error_stream(this->error_stream);

    if (hfst::twolcpre2::parse() != 0)
      {
        HFST_THROW(HfstException);
      }
    hfst::twolcpre2::complete_alphabet();
    std::ostringstream oss2;
    oss2 << hfst::twolcpre2::get_total_alphabet_symbol_queue() << " ";
    oss2 << hfst::twolcpre2::get_non_alphabet_symbol_queue();

    std::istringstream iss2(oss2.str());
    hfst::twolcpre3::set_input(iss2);
    hfst::twolcpre3::set_warning_stream(this->warning_stream);
    hfst::twolcpre3::set_error_stream(this->error_stream);
      
    OtherSymbolTransducer::set_transducer_type(command_line.format);
    hfst::twolcpre3::set_silent(command_line.be_quiet);
    hfst::twolcpre3::set_verbose(command_line.be_verbose);

    TwolCGrammar twolc_grammar(command_line.be_quiet,
                               command_line.be_verbose,
                               command_line.resolve_left_conflicts,
                               command_line.resolve_right_conflicts);
    hfst::twolcpre3::set_grammar(&twolc_grammar);
    if (hfst::twolcpre3::parse() != 0)
      {
        HFST_THROW(HfstException);
      }
  }
   
  void TwolcCompiler::store(HfstOutputStream & ostr)
  {   
    //hfst::twolcpre3::message("Compiling and storing rules.");
    hfst::twolcpre3::get_grammar()->compile_and_store(ostr);
  }

}


