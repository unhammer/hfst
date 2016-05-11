// Copyright (c) 2016 University of Helsinki                          
//                                                                    
// This library is free software; you can redistribute it and/or      
// modify it under the terms of the GNU Lesser General Public         
// License as published by the Free Software Foundation; either       
// version 3 of the License, or (at your option) any later version.
// See the file COPYING included with this distribution for more      
// information.

%module libhfst
// For type conversions between c++ and python
%include "std_string.i"
%include "std_vector.i"
%include "std_pair.i"
%include "std_set.i"
%include "std_map.i"
%include "exception.i"

%feature("autodoc", "3");

// We want warnings to be printed to standard error
%init %{
    hfst::set_warning_stream(&std::cerr);
%}

// Make swig aware of what hfst offers
%{
#define HFSTIMPORT
#include "HfstDataTypes.h"
#include "HfstTransducer.h"
#include "HfstOutputStream.h"
#include "HfstInputStream.h"
#include "HfstExceptionDefs.h"
#include "HfstTokenizer.h"
#include "HfstFlagDiacritics.h"
#include "parsers/XreCompiler.h"
#include "parsers/LexcCompiler.h"
#include "parsers/XfstCompiler.h"
#include "implementations/HfstTransitionGraph.h"
#include "implementations/optimized-lookup/pmatch.h"

// C++ extension code is located in separate files
#include "hfst_file_extensions.cc"
#include "hfst_extensions.cc"
#include "hfst_regex_extensions.cc"
#include "hfst_lexc_extensions.cc"
#include "hfst_xfst_extensions.cc"
#include "hfst_pmatch_extensions.cc"
#include "hfst_lookup_extensions.cc"
#include "hfst_rules_extensions.cc"
#include "hfst_prolog_extensions.cc"
%}

#ifdef _MSC_VER
%include <windows.h>
#endif

// Needed for conversion between c++ and python datatypes

%include "typemaps.i"

namespace std {
%template(StringVector) vector<string>;
%template(StringPair) pair<string, string>;
%template(StringPairVector) vector<pair<string, string > >;
%template(FloatVector) vector<float>;
%template(StringSet) set<string>;
%template(StringPairSet) set<pair<string, string> >;
%template(HfstTransducerVector) vector<hfst::HfstTransducer>;
%template(HfstSymbolSubstitutions) map<string, string>;
%template(HfstSymbolPairSubstitutions) map<pair<string, string>, pair<string, string> >;
%template(FooBarBaz) vector<hfst::implementations::HfstBasicTransition>;
%template(BarBazFoo) vector<unsigned int>;
%template(HfstBasicStates) vector<vector<hfst::implementations::HfstBasicTransition> >;
%template(HfstOneLevelPath) pair<float, vector<string> >;
%template(HfstOneLevelPaths) set<pair<float, vector<string> > >;
%template(HfstTwoLevelPath) pair<float, vector<pair<string, string > > >;
%template(HfstTwoLevelPaths) set<pair<float, vector<pair<string, string > > > >;
%template(HfstTransducerPair) pair<hfst::HfstTransducer, hfst::HfstTransducer>;
%template(HfstTransducerPairVector) vector<pair<hfst::HfstTransducer, hfst::HfstTransducer> >;
}


// ********** WHAT IS MADE AVAILABLE ON PYTHON ********** //

// *** HfstException and its subclasses (via module hfst.exceptions) *** //

class HfstException 
{
  public:
    HfstException();
    HfstException(const std::string&, const std::string&, size_t);
    ~HfstException();
};

class HfstTransducerTypeMismatchException : public HfstException { public: HfstTransducerTypeMismatchException(const std::string&, const std::string&, size_t); ~HfstTransducerTypeMismatchException(); };
class ImplementationTypeNotAvailableException : public HfstException { public: ImplementationTypeNotAvailableException(const std::string&, const std::string&, size_t); ~ImplementationTypeNotAvailableException(); };
class FunctionNotImplementedException : public HfstException { public: FunctionNotImplementedException(const std::string&, const std::string&, size_t); ~FunctionNotImplementedException(); };
class StreamNotReadableException : public HfstException { public: StreamNotReadableException(const std::string&, const std::string&, size_t); ~StreamNotReadableException(); };
class StreamCannotBeWrittenException : public HfstException { public: StreamCannotBeWrittenException(const std::string&, const std::string&, size_t); ~StreamCannotBeWrittenException(); };
class StreamIsClosedException : public HfstException { public: StreamIsClosedException(const std::string&, const std::string&, size_t); ~StreamIsClosedException(); };
class EndOfStreamException : public HfstException { public: EndOfStreamException(const std::string&, const std::string&, size_t); ~EndOfStreamException(); };
class TransducerIsCyclicException : public HfstException { public: TransducerIsCyclicException(const std::string&, const std::string&, size_t); ~TransducerIsCyclicException(); };
class NotTransducerStreamException : public HfstException { public: NotTransducerStreamException(const std::string&, const std::string&, size_t); ~NotTransducerStreamException(); };
class NotValidAttFormatException : public HfstException { public: NotValidAttFormatException(const std::string&, const std::string&, size_t); ~NotValidAttFormatException(); };
class NotValidPrologFormatException : public HfstException { public: NotValidPrologFormatException(const std::string&, const std::string&, size_t); ~NotValidPrologFormatException(); };
class NotValidLexcFormatException : public HfstException { public: NotValidLexcFormatException(const std::string&, const std::string&, size_t); ~NotValidLexcFormatException(); };
class StateIsNotFinalException : public HfstException { public: StateIsNotFinalException(const std::string&, const std::string&, size_t); ~StateIsNotFinalException(); };
class ContextTransducersAreNotAutomataException : public HfstException { public: ContextTransducersAreNotAutomataException(const std::string&, const std::string&, size_t); ~ContextTransducersAreNotAutomataException(); };
class TransducersAreNotAutomataException : public HfstException { public: TransducersAreNotAutomataException(const std::string&, const std::string&, size_t); ~TransducersAreNotAutomataException(); };
class StateIndexOutOfBoundsException : public HfstException { public: StateIndexOutOfBoundsException(const std::string&, const std::string&, size_t); ~StateIndexOutOfBoundsException(); };
class TransducerHeaderException : public HfstException { public: TransducerHeaderException(const std::string&, const std::string&, size_t); ~TransducerHeaderException(); };
class MissingOpenFstInputSymbolTableException : public HfstException { public: MissingOpenFstInputSymbolTableException(const std::string&, const std::string&, size_t); ~MissingOpenFstInputSymbolTableException(); };
class TransducerTypeMismatchException : public HfstException { public: TransducerTypeMismatchException(const std::string&, const std::string&, size_t); ~TransducerTypeMismatchException(); };
class EmptySetOfContextsException : public HfstException { public: EmptySetOfContextsException(const std::string&, const std::string&, size_t); ~EmptySetOfContextsException(); };
class SpecifiedTypeRequiredException : public HfstException { public: SpecifiedTypeRequiredException(const std::string&, const std::string&, size_t); ~SpecifiedTypeRequiredException(); };
class HfstFatalException : public HfstException { public: HfstFatalException(const std::string&, const std::string&, size_t); ~HfstFatalException(); };
class TransducerHasWrongTypeException : public HfstException { public: TransducerHasWrongTypeException(const std::string&, const std::string&, size_t); ~TransducerHasWrongTypeException(); };
class IncorrectUtf8CodingException : public HfstException { public: IncorrectUtf8CodingException(const std::string&, const std::string&, size_t); ~IncorrectUtf8CodingException(); };
class EmptyStringException : public HfstException { public: EmptyStringException(const std::string&, const std::string&, size_t); ~EmptyStringException(); };
class SymbolNotFoundException : public HfstException { public: SymbolNotFoundException(const std::string&, const std::string&, size_t); ~SymbolNotFoundException(); };
class MetadataException : public HfstException { public: MetadataException(const std::string&, const std::string&, size_t); ~MetadataException(); };
class FlagDiacriticsAreNotIdentitiesException : public HfstException { public: FlagDiacriticsAreNotIdentitiesException(const std::string&, const std::string&, size_t); ~FlagDiacriticsAreNotIdentitiesException(); };

namespace hfst
{

// Needed for conversion between c++ and python datatypes

typedef std::vector<std::string> StringVector;
typedef std::pair<std::string, std::string> StringPair;
typedef std::vector<std::pair<std::string, std::string> > StringPairVector;
typedef std::vector<float> FloatVector;
typedef std::set<std::string> StringSet;
typedef std::set<std::pair<std::string, std::string> > StringPairSet;
typedef std::pair<float, std::vector<std::string> > HfstOneLevelPath;
typedef std::set<std::pair<float, std::vector<std::string> > > HfstOneLevelPaths;
typedef std::pair<float, std::vector<std::pair<std::string, std::string > > > HfstTwoLevelPath;
typedef std::set<std::pair<float, std::vector<std::pair<std::string, std::string> > > > HfstTwoLevelPaths;
typedef std::map<std::string, std::string> HfstSymbolSubstitutions;
typedef std::map<std::pair<std::string, std::string>, std::pair<std::string, std::string> > HfstSymbolPairSubstitutions;
typedef std::vector<hfst::HfstTransducer> HfstTransducerVector;
typedef std::pair<hfst::HfstTransducer, hfst::HfstTransducer> HfstTransducerPair;
typedef std::vector<std::pair<hfst::HfstTransducer, hfst::HfstTransducer> > HfstTransducerPairVector;


// *** Basically a wrapper for C file *** //

class HfstFile {
  public:
    HfstFile();
    ~HfstFile();
    void write(const char * str);
    void close();
    bool is_eof(void);
};

HfstFile hfst_stdout();
HfstFile hfst_stdin();
HfstFile hfst_open(const char * filename, const char * mode) throw (StreamNotReadableException);


// *** Some enumerations *** //

enum ImplementationType
{ SFST_TYPE, TROPICAL_OPENFST_TYPE, LOG_OPENFST_TYPE, FOMA_TYPE,
  XFSM_TYPE, HFST_OL_TYPE, HFST_OLW_TYPE, HFST2_TYPE,
  UNSPECIFIED_TYPE, ERROR_TYPE };

enum PushType { TO_INITIAL_STATE, TO_FINAL_STATE };

bool is_diacritic(const std::string & symbol);
hfst::HfstTransducerVector compile_pmatch_expression(const std::string & pmatch);
 
%pythoncode %{
  def is_string(s):
      if isinstance(s, str):
         return True
      else:
        return False   
  def is_string_pair(sp):
      if not isinstance(sp, tuple):
         return False
      if len(sp) != 2:
         return False
      if not is_string(sp[0]):
         return False
      if not is_string(sp[1]):
         return False
      return True
  def is_string_vector(sv):
      if not isinstance(sv, tuple):
         return False
      for s in sv:
          if not is_string(s):
             return False
      return True
  def is_string_pair_vector(spv):
      if not isinstance(spv, tuple):
         return False
      for sp in spv:
          if not is_string_pair(sp):
             return False
      return True

  def two_level_paths_to_dict(tlps):
      retval = {}
      for tlp in tlps:
          input = ""
          output = ""
          for sp in tlp[1]:
              input += sp[0]
              output += sp[1]
          if input in retval:
              retval[input].append((output, tlp[0]))
          else:
              retval[input] = [(output, tlp[0])]
      return retval

  def one_level_paths_to_tuple(olps):
      retval = []
      for olp in olps:
          path = ""
          for s in olp[1]:
              path += s
          retval.append((path, olp[0]))
      return tuple(retval)
%}

// *** HfstTransducer *** //

// NOTE: all functions returning an HfstTransducer& are commented out and extended by replacing them with equivalent functions that return void.
// This is done in order to avoid use of references that are not handled well by swig/python.
// Some constructors and destructor are also redefined.

class HfstTransducer 
{
public:
  HfstTransducer();
  void set_name(const std::string &name);
  std::string get_name() const;
  hfst::ImplementationType get_type() const;
  void set_property(const std::string& property, const std::string& value);
  std::string get_property(const std::string& property) const;
  const std::map<std::string,std::string>& get_properties() const;
  bool compare(const HfstTransducer&, bool harmonize=true) const throw(TransducerTypeMismatchException);
  unsigned int number_of_states() const;
  unsigned int number_of_arcs() const;
  StringSet get_alphabet() const;
  bool is_cyclic() const;
  bool is_automaton() const;
  bool is_infinitely_ambiguous() const;
  bool is_lookup_infinitely_ambiguous(const std::string &) const;
  bool has_flag_diacritics() const;
  void insert_to_alphabet(const std::string &);
  void remove_from_alphabet(const std::string &);
  static bool is_implementation_type_available(hfst::ImplementationType type);
  int longest_path_size(bool obey_flags=true) const;

%extend {

  // First versions of all functions returning an HfstTransducer& that return void instead:

  void concatenate(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->concatenate(tr, harmonize); }
  void disjunct(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->disjunct(tr, harmonize); }
  void subtract(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->subtract(tr, harmonize); }
  void intersect(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->intersect(tr, harmonize); }
  void compose(const HfstTransducer& tr, bool harmonize=true) throw(TransducerTypeMismatchException) { self->compose(tr, harmonize); }
  void compose_intersect(const HfstTransducerVector &v, bool invert=false, bool harmonize=true) { self->compose_intersect(v, invert, harmonize); }
  void priority_union(const HfstTransducer &another) { self->priority_union(another); }
  void lenient_composition(const HfstTransducer &another, bool harmonize=true) { self->lenient_composition(another, harmonize); }
  void cross_product(const HfstTransducer &another, bool harmonize=true) throw(TransducersAreNotAutomataException) { self->cross_product(another, harmonize); }
  void shuffle(const HfstTransducer &another, bool harmonize=true) { self->shuffle(another, harmonize); }
  void remove_epsilons() { self->remove_epsilons(); }
  void determinize() { self->determinize(); }
  void minimize() { self->minimize(); }
  void prune() { self->prune(); }
  void eliminate_flags() { self->eliminate_flags(); }
  void eliminate_flag(const std::string& f) throw(HfstException) { self->eliminate_flag(f); }
  void n_best(unsigned int n) { self->n_best(n); }
  void convert(ImplementationType impl) { self->convert(impl); }
  void repeat_star() { self->repeat_star(); }
  void repeat_plus() { self->repeat_plus(); }
  void repeat_n(unsigned int n) { self->repeat_n(n); }
  void repeat_n_to_k(unsigned int n, unsigned int k) { self->repeat_n_to_k(n, k); }
  void repeat_n_minus(unsigned int n) { self->repeat_n_minus(n); }
  void repeat_n_plus(unsigned int n) { self->repeat_n_plus(n); }
  void invert() { self->invert(); }
  void reverse() { self->reverse(); }
  void input_project() { self->input_project(); }
  void output_project() { self->output_project(); }
  void optionalize() { self->optionalize(); }
  void insert_freely(const StringPair &symbol_pair, bool harmonize=true) { self->insert_freely(symbol_pair, harmonize); }
  void insert_freely(const HfstTransducer &tr, bool harmonize=true) { self->insert_freely(tr, harmonize); }
  void substitute_symbol(const std::string &old_symbol, const std::string &new_symbol, bool input_side=true, bool output_side=true) { self->substitute_symbol(old_symbol, new_symbol, input_side, output_side); }
  void substitute_symbol_pair(const StringPair &old_symbol_pair, const StringPair &new_symbol_pair) { self->substitute_symbol_pair(old_symbol_pair, new_symbol_pair); }
  void substitute_symbol_pair_with_set(const StringPair &old_symbol_pair, const hfst::StringPairSet &new_symbol_pair_set) { self->substitute_symbol_pair_with_set(old_symbol_pair, new_symbol_pair_set); }
  void substitute_symbol_pair_with_transducer(const StringPair &symbol_pair, HfstTransducer &transducer, bool harmonize=true) { self->substitute_symbol_pair_with_transducer(symbol_pair, transducer, harmonize); }
  void substitute_symbols(const hfst::HfstSymbolSubstitutions &substitutions) { self->substitute_symbols(substitutions); } // alias for the previous function which is shadowed
  void substitute_symbol_pairs(const hfst::HfstSymbolPairSubstitutions &substitutions) { self->substitute_symbol_pairs(substitutions); } // alias for the previous function which is shadowed
  void set_final_weights(float weight, bool increment=false) { self->set_final_weights(weight, increment); };
  void push_weights(hfst::PushType type) { self->push_weights(type); };

  // And some aliases:
  // 'union' is a reserved word in python, so it cannot be used as an alias for function 'disjunct' 
  void minus(const HfstTransducer& t, bool harmonize=true) { $self->subtract(t, harmonize); }
  void conjunct(const HfstTransducer& t, bool harmonize=true) { $self->intersect(t, harmonize); }

  // Then the actual extensions:

    HfstTransducer(const hfst::HfstTransducer & t) { return hfst::copy_hfst_transducer(t); }
    HfstTransducer(const hfst::implementations::HfstBasicTransducer & t) { return hfst::copy_hfst_transducer_from_basic_transducer(t); }
    HfstTransducer(const hfst::implementations::HfstBasicTransducer & t, hfst::ImplementationType impl) { return hfst::copy_hfst_transducer_from_basic_transducer(t, impl); }
    ~HfstTransducer()
    {
        if ($self->get_type() == hfst::UNSPECIFIED_TYPE || $self->get_type() == hfst::ERROR_TYPE)
        {
            return;
        }
        delete $self;
    }
    // For python's 'print'
    char *__str__() {
         std::ostringstream oss;
         hfst::implementations::HfstBasicTransducer fsm(*$self);
         fsm.write_in_att_format(oss,true);
         return strdup(oss.str().c_str());
    }
    void write(hfst::HfstOutputStream & os) { (void) os.redirect(*$self); }
    void write_att(hfst::HfstFile & f, bool write_weights=true) { $self->write_in_att_format(f.get_file(), write_weights); }
    //void write_prolog(hfst::HfstFile & f, const std::string & name, bool write_weights=true) { $self->write_in_prolog_format(f.get_file(), name, write_weights); }

    hfst::HfstTwoLevelPaths extract_shortest_paths_()
    {
        hfst::HfstTwoLevelPaths results;
        $self->extract_shortest_paths(results);
        return results;
    }
    hfst::HfstTwoLevelPaths extract_longest_paths_(bool obey_flags)
    {
        hfst::HfstTwoLevelPaths results;
        $self->extract_longest_paths(results, obey_flags);
        return results;
    }
    hfst::HfstTwoLevelPaths extract_paths_(int max_num=-1, int cycles=-1) const throw(TransducerIsCyclicException)
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_paths(results, max_num, cycles);
      return results;
    }
    hfst::HfstTwoLevelPaths extract_paths_fd_(int max_num=-1, int cycles=-1, bool filter_fd=true) const throw(TransducerIsCyclicException)
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_paths_fd(results, max_num, cycles, filter_fd);
      return results;
    }
    hfst::HfstTwoLevelPaths extract_random_paths_(int max_num) const
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_random_paths(results, max_num);
      return results;
    }
    hfst::HfstTwoLevelPaths extract_random_paths_fd_(int max_num, bool filter_fd) const
    {
      hfst::HfstTwoLevelPaths results;
      $self->extract_random_paths_fd(results, max_num, filter_fd);
      return results;
    }

    HfstOneLevelPaths lookup_vector(const StringVector& s, int limit = -1, double time_cutoff = 0.0) const throw(FunctionNotImplementedException)
    { 
      return hfst::lookup_vector_($self, false /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths lookup_fd_vector(const StringVector& s, int limit = -1, double time_cutoff = 0.0) const throw(FunctionNotImplementedException)
    { 
      return hfst::lookup_vector_($self, true /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths lookup_fd_string(const std::string& s, int limit = -1, double time_cutoff = 0.0) const throw(FunctionNotImplementedException)
    { 
      return hfst::lookup_string_($self, true /*fd*/, s, limit, time_cutoff);
    }
    HfstOneLevelPaths lookup_string(const std::string & s, int limit = -1, double time_cutoff = 0.0) const throw(FunctionNotImplementedException)
    { 
      return hfst::lookup_string_($self, false /*fd*/, s, limit, time_cutoff);
    }

%pythoncode %{

  def write_to_file(self, filename_):
      ostr = HfstOutputStream(filename=filename_, type=self.get_type(), hfst_format=True)
      ostr.write(self)
      ostr.close()

  def read_from_file(filename_):
      istr = HfstInputStream(filename_)
      tr = istr.read()
      istr.close()
      return tr

  def write_prolog(self, f, write_weights=True):
      fsm = HfstBasicTransducer(self)
      fsm.name = self.get_name()
      prologstr = fsm.get_prolog_string(write_weights)
      f.write(prologstr)

  def lookup(self, input, **kvargs):
      
      obey_flags=True
      max_number=-1
      time_cutoff=0.0
      output='tuple' # 'tuple' (default), 'text', 'raw'

      for k,v in kvargs.items():
          if k == 'obey_flags':
             if v == 'True':
                pass
             elif v == 'False':
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'True' and 'False'.")
          elif k == 'output':
             if v == 'text':
                output='text'
             elif v == 'raw':
                output='raw'
             elif v == 'tuple':
                output='tuple'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'tuple' (default), 'text', 'raw'.")
          elif k == 'max_number' :
             max_number=v
          elif k == 'time_cutoff' :
             time_cutoff=v
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval=0

      if isinstance(input, tuple):
         if obey_flags:
            retval=self.lookup_fd_vector(input, max_number, time_cutoff)
         else:
            retval=self.lookup_vector(input, max_number, time_cutoff)
      elif isinstance(input, str):
         if obey_flags:
            retval=self.lookup_fd_string(input, max_number, time_cutoff)
         else:
            retval=self.lookup_string(input, max_number, time_cutoff)
      else:
         try:
            if obey_flags:
                retval=self.lookup_fd_string(str(input), max_number, time_cutoff)
            else:
                retval=self.lookup_string(str(input), max_number, time_cutoff)         
         except:
            raise RuntimeError('Input argument must be string or tuple.')

      if output == 'text':
         return one_level_paths_to_string(retval)
      elif output == 'tuple':
         return one_level_paths_to_tuple(retval)
      else:
         return retval

  def extract_longest_paths(self, **kvargs):
      obey_flags=True
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kvargs.items():
          if k == 'obey_flags':
             if v == 'True':
                pass
             elif v == 'False':
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'True' and 'False'.")
          elif k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self.extract_longest_paths_(obey_flags)

      if output == 'text':
         return two_level_paths_to_string(retval)
      elif output == 'dict':
         return two_level_paths_to_dict(retval)
      else:
         return retval

  def extract_shortest_paths(self, **kvargs):
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kvargs.items():
          if k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self.extract_shortest_paths_()

      if output == 'text':
         return two_level_paths_to_string(retval)
      elif output == 'dict':
         return two_level_paths_to_dict(retval)
      else:
         return retval

  def extract_paths(self, **kvargs):

      obey_flags=True
      filter_flags=True
      max_cycles=-1
      max_number=-1
      random=False
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kvargs.items():
          if k == 'obey_flags' :
             if v == 'True':
                pass
             elif v == 'False':
                obey_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'True' and 'False'.")
          elif k == 'filter_flags' :
             if v == 'True':
                pass
             elif v == 'False':
                filter_flags=False
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'True' and 'False'.")
          elif k == 'max_cycles' :
             max_cycles=v
          elif k == 'max_number' :
             max_number=v
          elif k == 'random' :
             if v == 'False':
                pass
             elif v == 'True':
                random=True
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'True' and 'False'.")
          elif k == 'output':
             if v == 'text':
                output = 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval=0

      if obey_flags :
         if random :
            retval=self.extract_random_paths_fd_(max_number, filter_flags)
         else :
            retval=self.extract_paths_fd_(max_number, max_cycles)
      else :
         if random :
            retval=self.extract_random_paths_(max_number)  
         else :   
            retval=self.extract_paths_(max_number, max_cycles)

      if output == 'text':
         return two_level_paths_to_string(retval)
      elif output == 'dict':
         return two_level_paths_to_dict(retval)
      else:
         return retval

  def substitute(self, s, S=None, **kvargs):

      if S == None:
         if not isinstance(s, dict):
            raise RuntimeError('Sole input argument must be a dictionary.')

         subst_type=""

         for k, v in s.items():
             if is_string(k):
                if subst_type == "":
                   subst_type="string"
                elif subst_type == "string pair":
                   raise RuntimeError('')
                if not is_string(v):
                   raise RuntimeError('')
             elif is_string_pair(k):
                if subst_type == "":
                   subst_type="string pair"
                elif subst_type == "string":
                   raise RuntimeError('')
                if not is_string_pair(v):
                   raise RuntimeError('')
             else:
                raise RuntimeError('')

         if subst_type == "string":
            return self.substitute_symbols(s)
         else:
            return self.substitute_symbol_pairs(s)

      if is_string(s):
         if is_string(S):
            input=True
            output=True
            for k,v in kvargs.items():
                if k == 'input':
                   if v == False:
                      input=False
                elif k == 'output':
                   if v == False:
                      output=False
                else:
                   raise RuntimeError('Free argument not recognized.')
            return self.substitute_symbol(s, S, input, output)
         else:
            raise RuntimeError('...')
      elif is_string_pair(s):
         if is_string_pair(S):
            return self.substitute_symbol_pair(s, S)
         elif is_string_pair_vector(S):
            return self.substitute_symbol_pair_with_set(s, S)
         elif isinstance(S, HfstTransducer):
            return self.substitute_symbol_pair_with_transducer(s, S, True)
         else:
            raise RuntimeError('...')
      else:
         raise RuntimeError('...')
%}

};

}; // class HfstTransducer


// *** HfstOutputStream *** //

hfst::HfstOutputStream * create_hfst_output_stream(const std::string & filename, hfst::ImplementationType type, bool hfst_format);

class HfstOutputStream
{
public:
~HfstOutputStream(void);
HfstOutputStream &flush();
void close(void);

%extend {

void write(hfst::HfstTransducer transducer) throw(StreamIsClosedException) { $self->redirect(transducer); }
HfstOutputStream() { return new hfst::HfstOutputStream(hfst::get_default_fst_type()); }

%pythoncode %{

def __init__(self, **kvargs):
    filename = ""
    hfst_format = True
    type = _libhfst.get_default_fst_type()
    for k,v in kvargs.items():
        if k == 'filename':
           filename = v
        if k == 'hfst_format':
           hfst_format = v
        if k == 'type':
           type = v
    if filename == "":
       self.this = _libhfst.create_hfst_output_stream("", type, hfst_format)
    else:
       self.this = _libhfst.create_hfst_output_stream(filename, type, hfst_format)
%}

}

}; // class HfstOutputStream

// *** HfstInputStream *** //

class HfstInputStream
{
public:
    HfstInputStream(void) throw(StreamNotReadableException, NotTransducerStreamException, EndOfStreamException, TransducerHeaderException);
    HfstInputStream(const std::string &filename) throw(StreamNotReadableException, NotTransducerStreamException, EndOfStreamException, TransducerHeaderException);
    ~HfstInputStream(void);
    void close(void);
    bool is_eof(void);
    bool is_bad(void);
    bool is_good(void);
    ImplementationType get_type(void) const throw(TransducerTypeMismatchException);

%extend {

hfst::HfstTransducer * read() throw (EndOfStreamException) { return new hfst::HfstTransducer(*($self)); }

%pythoncode %{

def __iter__(self):
    return self

# Python 2
def next(self):
    if self.is_eof():
        raise StopIteration
    else:
        return self.read();

# Python 3
def __next__(self):
    return self.next()

%}

}

}; // class HfstInputStream


// *** HfstTokenizer *** //
  
  class HfstTokenizer
  {    
  public:
     HfstTokenizer();
     void add_skip_symbol(const std::string &symbol);
     void add_multichar_symbol(const std::string& symbol);
     StringPairVector tokenize(const std::string &input_string) const;
     StringVector tokenize_one_level(const std::string &input_string) const;
     static StringPairVector tokenize_space_separated(const std::string & str);
     StringPairVector tokenize(const std::string &input_string,
                              const std::string &output_string) const;
     static void check_utf8_correctness(const std::string &input_string);
  };

namespace implementations {

  class HfstBasicTransducer;
  class HfstBasicTransition;
  typedef unsigned int HfstState;

  typedef std::vector<std::vector<hfst::implementations::HfstBasicTransition> > HfstBasicStates;

// *** HfstBasicTransducer *** //

class HfstBasicTransducer {

  public:

    typedef std::vector<HfstBasicTransition> HfstTransitions;

    HfstBasicTransducer(void);
    HfstBasicTransducer(const HfstBasicTransducer &graph);
    HfstBasicTransducer(const hfst::HfstTransducer &transducer);

    std::string name;
    void add_symbol_to_alphabet(const std::string &symbol);
    void remove_symbol_from_alphabet(const std::string &symbol);
    void remove_symbols_from_alphabet(const StringSet &symbols);
    void add_symbols_to_alphabet(const StringSet &symbols);
    // shadowed by the previous function: void add_symbols_to_alphabet(const StringPairSet &symbols);
    std::set<std::string> symbols_used();
    void prune_alphabet(bool force=true);
    const std::set<std::string> &get_alphabet() const;
    StringPairSet get_transition_pairs() const;
    HfstState add_state(void);
    HfstState add_state(HfstState s);
    HfstState get_max_state() const;
    std::vector<HfstState> states() const;
    void add_transition(HfstState s, const hfst::implementations::HfstBasicTransition & transition, bool add_symbols_to_alphabet=true);
    void remove_transition(HfstState s, const hfst::implementations::HfstBasicTransition & transition, bool remove_symbols_from_alphabet=false);
    bool is_final_state(HfstState s) const;
    float get_final_weight(HfstState s) const throw(StateIsNotFinalException, StateIndexOutOfBoundsException);
    void set_final_weight(HfstState s, const float & weight);
    const std::vector<HfstBasicTransition> & transitions(HfstState s) const;
    bool is_infinitely_ambiguous();
    bool is_lookup_infinitely_ambiguous(const StringVector & s);
    int longest_path_size();
    hfst::implementations::HfstBasicStates states_and_transitions() const;



%extend {

    void substitute_symbol(const std::string &old_symbol, const std::string &new_symbol, bool input_side=true, bool output_side=true) { self->substitute_symbol(old_symbol, new_symbol, input_side, output_side); }
    void substitute_symbol_pair(const StringPair &old_symbol_pair, const StringPair &new_symbol_pair) { self->substitute_symbol_pair(old_symbol_pair, new_symbol_pair); }
    void substitute_symbol_pair_with_set(const StringPair &old_symbol_pair, const hfst::StringPairSet &new_symbol_pair_set) { self->substitute_symbol_pair_with_set(old_symbol_pair, new_symbol_pair_set); }
    void substitute_symbol_pair_with_transducer(const StringPair &symbol_pair, HfstBasicTransducer &transducer) { self->substitute_symbol_pair_with_transducer(symbol_pair, transducer); }
    void substitute_symbols(const hfst::HfstSymbolSubstitutions &substitutions) { self->substitute_symbols(substitutions); } // alias for the previous function which is shadowed
    void substitute_symbol_pairs(const hfst::HfstSymbolPairSubstitutions &substitutions) { self->substitute_symbol_pairs(substitutions); } // alias for the previous function which is shadowed
    void insert_freely(const StringPair &symbol_pair, float weight) { self->insert_freely(symbol_pair, weight); }
    void insert_freely(const HfstBasicTransducer &tr) { self->insert_freely(tr); }
    void sort_arcs() { self->sort_arcs(); }
    void disjunct(const StringPairVector &spv, float weight) { self->disjunct(spv, weight); }
    void harmonize(HfstBasicTransducer &another) { self->harmonize(another); }

  HfstTwoLevelPaths lookup_fd_(const StringVector &lookup_path, size_t * infinite_cutoff, float * max_weight)
  {
    hfst::HfstTwoLevelPaths results;
    $self->lookup_fd(lookup_path, results, infinite_cutoff, max_weight);
    return results;
  }
  //void write_prolog(hfst::HfstFile & f, const std::string & name, bool write_weights=true) { $self->write_in_prolog_format(f.get_file(), name, write_weights); }

  std::string get_prolog_string(bool write_weights)
  {
    std::ostringstream oss;
    $self->write_in_prolog_format(oss, self->name, write_weights);
    return oss.str();
  }

  //static HfstBasicTransducer read_prolog(hfst::HfstFile & f) {
  //  unsigned int linecount = 0;
  //  return hfst::implementations::HfstBasicTransducer::read_in_prolog_format(f.get_file(), linecount);
  //}
  void write_xfst(hfst::HfstFile & f, bool write_weights=true) { $self->write_in_xfst_format(f.get_file(), write_weights); }
  void write_att(hfst::HfstFile & f, bool write_weights=true) { $self->write_in_att_format(f.get_file(), write_weights); }
  static HfstBasicTransducer read_att(hfst::HfstFile & f, std::string epsilon="@_EPSILON_SYMBOL_@") throw(EndOfStreamException, NotValidAttFormatException) {
    unsigned int linecount = 0;
    return hfst::implementations::HfstBasicTransducer::read_in_att_format(f.get_file(), epsilon, linecount);
  }

  char * __str__()
  {
    static char str[1024];
    $self->write_in_att_format(str, true); // write_weights=true  
    return str;
  }

  void add_transition(HfstState source, HfstState target, std::string input, std::string output, float weight=0) {
    hfst::implementations::HfstBasicTransition tr(target, input, output, weight);
    $self->add_transition(source, tr);
  }

%pythoncode %{
  def __iter__(self):
      return self.states_and_transitions().__iter__()

  def __enumerate__(self):
      return enumerate(self.states_and_transitions())

  def write_prolog(self, f, write_weights=True):
      prologstr = self.get_prolog_string(write_weights)
      f.write(prologstr)

  def lookup_fd(self, lookup_path, **kvargs):
      max_weight = None
      infinite_cutoff = None
      output='dict' # 'dict' (default), 'text', 'raw'

      for k,v in kvargs.items():
          if k == 'max_weight' :
             max_weight=v
          elif k == 'infinite_cutoff' :
             infinite_cutoff=v
          elif k == 'output':
             if v == 'text':
                output == 'text'
             elif v == 'raw':
                output='raw'
             elif v == 'dict':
                output='dict'
             else:
                print('Warning: ignoring argument %s as it has value %s.' % (k, v))
                print("Possible values are 'dict' (default), 'text', 'raw'.")
          else:
             print('Warning: ignoring unknown argument %s.' % (k))

      retval = self.lookup_fd_(lookup_path, infinite_cutoff, max_weight)

      if output == 'text':
         return two_level_paths_to_string(retval)
      elif output == 'dict':
         return two_level_paths_to_dict(retval)
      else:
         return retval

  def substitute(self, s, S=None, **kvargs):

      if S == None:
         if not isinstance(s, dict):
            raise RuntimeError('First input argument must be a dictionary.')

         subst_type=""

         for k, v in s.items():
             if is_string(k):
                if subst_type == "":
                   subst_type="string"
                elif subst_type == "string pair":
                   raise RuntimeError('')
                if not is_string(v):
                   raise RuntimeError('')
             elif is_string_pair(k):
                if subst_type == "":
                   subst_type="string pair"
                elif subst_type == "string":
                   raise RuntimeError('')
                if not is_string_pair(v):
                   raise RuntimeError('')
             else:
                raise RuntimeError('')

         if subst_type == "string":
            return self.substitute_symbols(s)
         else:
            return self.substitute_symbol_pairs(s)

      if is_string(s):
         if is_string(S):
            input=True
            output=True
            for k,v in kvargs.items():
                if k == 'input':
                   if v == False:
                      input=False
                elif k == 'output':
                   if v == False:
                      output=False
                else:
                   raise RuntimeError('Free argument not recognized.')
            return self.substitute_symbol(s, S, input, output)
         else:
            raise RuntimeError('...')
      elif is_string_pair(s):
         if is_string_pair(S):
            return self.substitute_symbol_pair(s, S)
         elif is_string_pair_vector(S):
            return self.substitute_symbol_pair_with_set(s, S)
         elif isinstance(S, HfstBasicTransducer):
            return self.substitute_symbol_pair_with_transducer(s, S)
         else:
            raise RuntimeError('...')
      else:
         raise RuntimeError('...')

%}

}
        
}; // class HfstBasicTransducer

// *** HfstBasicTransition *** //

class HfstBasicTransition {
  public:
    HfstBasicTransition();
    HfstBasicTransition(hfst::implementations::HfstState, std::string, std::string, float);
    ~HfstBasicTransition();
    HfstState get_target_state() const;
    std::string get_input_symbol() const;
    std::string get_output_symbol() const;
    float get_weight() const;
  
%extend{
    char *__str__() {
      static char str[1024];
      sprintf(str, "%u %s %s %f", $self->get_target_state(), $self->get_input_symbol().c_str(), $self->get_output_symbol().c_str(), $self->get_weight());
      return str;
    }
}

}; // class HfstBasicTransition

} // namespace implementations


// *** PmatchCompiler class is not visible via python, compile_pmatch_expression and compile_pmatch_file are enough. *** //

// *** XreCompiler: offer only a limited set of functions ***

namespace xre {
class XreCompiler
{
  public:
  XreCompiler();
  XreCompiler(hfst::ImplementationType impl);
  void define_list(const std::string& name, const std::set<std::string>& symbol_list);
  bool define_function(const std::string& name, unsigned int arguments, const std::string& xre);
  bool is_definition(const std::string& name);
  bool is_function_definition(const std::string& name);
  void undefine(const std::string& name);
  HfstTransducer* compile(const std::string& xre);
  void set_verbosity(bool verbose);
  bool getOutputToConsole();
  void set_expand_definitions(bool expand); // TODO: should this be set automatically to True?

  // *** Some wrappers *** //
%extend{
  void define_xre(const std::string& name, const std::string& xre)
  {
    self->define(name, xre);
  }
  void define_transducer(const std::string& name, const HfstTransducer & transducer)
  {
    self->define(name, transducer);
  }
  void setOutputToConsole(bool value) 
  {
    (void)self->setOutputToConsole(value);
  }
}

};
}

// *** The LexcCompiler functions are offered only because they are needed in some python functions... *** //

namespace lexc {
  class LexcCompiler
  {
    public:
      LexcCompiler();
      LexcCompiler(hfst::ImplementationType impl);
      LexcCompiler(hfst::ImplementationType impl, bool withFlags, bool alignStrings);
      LexcCompiler& setVerbosity(unsigned int verbose);
      void setOutputToConsole(bool);
  };

}

// *** The XfstCompiler functions are offered only because they are needed in some python functions... *** //

namespace xfst {
  class XfstCompiler
  {
    public:
      XfstCompiler();
      XfstCompiler(hfst::ImplementationType impl);
      XfstCompiler& setOutputToConsole(bool value);
      XfstCompiler& setVerbosity(bool verbosity);
      XfstCompiler& set(const char* name, const char* text);
  };
}


std::string hfst::get_hfst_regex_error_message();
hfst::HfstTransducer * hfst::hfst_regex(hfst::xre::XreCompiler & comp, const std::string & regex_string, const std::string & error_stream);

char * hfst::get_hfst_xfst_string_one();
char * hfst::get_hfst_xfst_string_two();
int hfst::hfst_compile_xfst_to_string_one(hfst::xfst::XfstCompiler & comp, std::string input);
int hfst::hfst_compile_xfst(hfst::xfst::XfstCompiler & comp, std::string input, const std::string & output_stream, const std::string & error_stream);

std::string hfst::get_hfst_lexc_output();
hfst::HfstTransducer * hfst::hfst_compile_lexc(hfst::lexc::LexcCompiler & comp, const std::string & filename, const std::string & error_stream);

void hfst::set_default_fst_type(hfst::ImplementationType t);
hfst::ImplementationType hfst::get_default_fst_type();
std::string hfst::fst_type_to_string(hfst::ImplementationType t);

//hfst::HfstTransducer * hfst::read_att(hfst::HfstFile & f, std::string epsilon="@_EPSILON_SYMBOL_@") throw(EndOfStreamException, NotValidAttFormatException);
//hfst::HfstTransducer * hfst::read_prolog(hfst::HfstFile & f) throw(EndOfStreamException);

std::string hfst::one_level_paths_to_string(const HfstOneLevelPaths &);
std::string hfst::two_level_paths_to_string(const HfstTwoLevelPaths &);

bool parse_prolog_network_line(const std::string & line, hfst::implementations::HfstBasicTransducer * graph);
bool parse_prolog_arc_line(const std::string & line, hfst::implementations::HfstBasicTransducer * graph);
bool parse_prolog_symbol_line(const std::string & line, hfst::implementations::HfstBasicTransducer * graph);
bool parse_prolog_final_line(const std::string & line, hfst::implementations::HfstBasicTransducer * graph);

// *** hfst_rules (via module hfst.rules) *** //

namespace hfst_rules {

  HfstTransducer two_level_if(const HfstTransducerPair & context, const StringPairSet & mappings, const StringPairSet & alphabet);
  HfstTransducer two_level_only_if(const HfstTransducerPair &context, const StringPairSet &mappings, const StringPairSet &alphabet); 
  HfstTransducer two_level_if_and_only_if(const HfstTransducerPair &context, const StringPairSet &mappings, const StringPairSet &alphabet); 
  HfstTransducer replace_down(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer replace_down_karttunen(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer replace_right(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer replace_left(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer replace_up(const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer replace_down(const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_up(const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_up(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_down(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_down_karttunen(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_left(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer left_replace_right(const HfstTransducerPair &context, const HfstTransducer &mapping, bool optional, const StringPairSet &alphabet); 
  HfstTransducer restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer surface_restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer surface_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer surface_restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer deep_restriction(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer deep_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet); 
  HfstTransducer deep_restriction_and_coercion(const HfstTransducerPairVector &contexts, const HfstTransducer &mapping, const StringPairSet &alphabet);

} // namespace hfst_rules


} // namespace hfst

// *** PmatchContainer *** //

namespace hfst_ol {
    class PmatchContainer
    {
    public:
        PmatchContainer(void);
        PmatchContainer(hfst::HfstTransducerVector transducers);
        ~PmatchContainer(void);
        std::string match(const std::string & input, double time_cutoff = 0.0);
        std::string get_profiling_info(void);
        void set_verbose(bool b);
        void set_extract_tags_mode(bool b);
        void set_profile(bool b);

}; // class PmatchContainer
} // namespace hfst_ol


// *** Actual python extensions *** //
 
%pythoncode %{

from sys import stdout
 
EPSILON='@_EPSILON_SYMBOL_@'
UNKNOWN='@_UNKNOWN_SYMBOL_@'
IDENTITY='@_IDENTITY_SYMBOL_@'

OUTPUT_TO_CONSOLE=False
def set_output_to_console(val):
    global OUTPUT_TO_CONSOLE
    OUTPUT_TO_CONSOLE=val
def get_output_to_console():
    return OUTPUT_TO_CONSOLE

def regex(re, **kvargs):
    type = _libhfst.get_default_fst_type()
    to_console=get_output_to_console()
    import sys
    err=None

    for k,v in kvargs.items():
      if k == 'output_to_console':
          to_console=v
      if k == 'error':
          err=v
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    comp = XreCompiler(type)
    comp.setOutputToConsole(to_console)

    if err == None:
       return _libhfst.hfst_regex(comp, re, "")
    elif err == sys.stdout:
       return _libhfst.hfst_regex(comp, re, "cout")
    elif err == sys.stderr:
       return _libhfst.hfst_regex(comp, re, "cerr")
    else:
       retval = _libhfst.hfst_regex(comp, re, "")
       err.write(_libhfst.get_hfst_regex_error_message())
       return retval

# internal function
def replace_symbols(symbol, epsilonstr=EPSILON):
    if symbol == epsilonstr:
       return EPSILON
    if symbol == "@0@":
       return EPSILON
    symbol = symbol.replace("@_SPACE_@", " ")
    symbol = symbol.replace("@_TAB_@", "\t")
    symbol = symbol.replace("@_COLON_@", ":")
    return symbol

# internal function
def parse_att_line(line, fsm, epsilonstr=EPSILON):
    # get rid of extra whitespace
    line = line.replace('\t',' ')
    line = " ".join(line.split())
    fields = line.split(' ')
    try:
        if len(fields) == 1:
           if fields[0] == '': # empty transducer...
               return True
           fsm.add_state(int(fields[0]))
           fsm.set_final_weight(int(fields[0]), 0)
        elif len(fields) == 2:
           fsm.add_state(int(fields[0]))
           fsm.set_final_weight(int(fields[0]), float(fields[1]))
        elif len(fields) == 4:
           fsm.add_transition(int(fields[0]), int(fields[1]), replace_symbols(fields[2]), replace_symbols(fields[3]), 0)
        elif len(fields) == 5:
           fsm.add_transition(int(fields[0]), int(fields[1]), replace_symbols(fields[2]), replace_symbols(fields[3]), float(fields[4]))
        else:
           return False
    except ValueError as e:
        return False
    return True

def read_att_string(att):
    fsm = HfstBasicTransducer()
    lines = att.split('\n')
    for line in lines:
        if not parse_att_line(line, fsm):
           raise NotValidAttFormatException("","",0)
    return HfstTransducer(fsm, _libhfst.get_default_fst_type())

def read_att_input():
    fsm = HfstBasicTransducer()
    while True:
        line = input().rstrip()
        if line == "":
           break
        if not parse_att_line(line, fsm):
           raise NotValidAttFormatException("","",0)
    return HfstTransducer(fsm, _libhfst.get_default_fst_type())

def read_att_transducer(f, epsilonstr=EPSILON):
    linecount = 0
    fsm = HfstBasicTransducer()
    while True:
        line = f.readline()
        if line == "":
           if linecount == 0:
              raise EndOfStreamException("","",0)
           else:
              break
        if line[0] == '-':
           break
        linecount = linecount + 1
        if not parse_att_line(line, fsm, epsilonstr):
           raise NotValidAttFormatException("","",0)
    return HfstTransducer(fsm, _libhfst.get_default_fst_type())

def read_prolog_transducer(f):
    fsm = HfstBasicTransducer()
    
    line = ""
    while(True):
        line = f.readline()
        if line == "":
           raise EndOfStreamException("","",0)
        line = line.rstrip()
        if line == "":
           pass # allow extra prolog separator(s)
        if line[0] == '#':
           pass # comment line
        else:
           break

    if not parse_prolog_network_line(line, fsm):
       raise NotValidPrologFormatException(line,"",0)

    while(True):
        line = f.readline()
        if (line == ""):
           retval = HfstTransducer(fsm, _libhfst.get_default_fst_type())
           retval.set_name(fsm.name)
           return retval
        line = line.rstrip()
        if line == "":  # prolog separator
           retval = HfstTransducer(fsm, _libhfst.get_default_fst_type())
           retval.set_name(fsm.name)
           return retval           
        if parse_prolog_arc_line(line, fsm):
           pass
        elif parse_prolog_final_line(line, fsm):
           pass
        elif parse_prolog_symbol_line(line, fsm):
           pass
        else:
           raise NotValidPrologFormatException(line,"",0)

def start_xfst(**kvargs):
    import sys
    idle = 'idlelib' in sys.modules
    if idle:
        print('It seems that you are running python in in IDLE. Note that all output from xfst will be buffered.')
        print('This means that all warnings, e.g. about time-consuming operations, will be printed only after the operation is carried out.')
        print('Consider running python from shell, for example command prompt, if you wish to see output with no delays.')

    type = _libhfst.get_default_fst_type()
    quit_on_fail = 'OFF'
    to_console=get_output_to_console()
    for k,v in kvargs.items():
      if k == 'type':
        type = v
      elif k == 'output_to_console':
        to_console=v
      elif k == 'quit_on_fail':
        if v == True:
          quit_on_fail='ON'
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    comp = XfstCompiler(type)
    comp.setReadInteractiveTextFromStdin(True)

    if to_console and idle:
        print('Cannot output to console when running libhfst from IDLE.')
        to_console=False
    comp.setOutputToConsole(to_console)
    comp.set('quit-on-fail', quit_on_fail)

    expression=""
    import sys
    while True:
        expression += input(comp.get_prompt()).rstrip()
        if expression[-1] == '\\':
           expression = expression[:-2] + '\n'
           continue
        retval = -1
        if idle:
            retval = _libhfst.hfst_compile_xfst_to_string_one(comp, expression)
            stdout.write(_libhfst.get_hfst_xfst_string_one())
        else:
            retval = comp.parse_line(expression + "\n")
        if retval != 0:
           print("expression '%s' could not be parsed" % expression)
           if comp.get("quit-on-fail") == "ON":
              return
        if comp.quit_requested():
           break
        expression = ""

def compile_xfst_file(filename, **kvargs):
    verbosity=0
    quit_on_fail='ON'
    type = _libhfst.get_default_fst_type()
    output=None
    error=None
    to_console=get_output_to_console()

    for k,v in kvargs.items():
      if k == 'verbosity':
        verbosity=v
      elif k == 'quit_on_fail':
        if v == False:
          quit_on_fail='OFF'
      elif k == 'output':
          output=v
      elif k == 'error':
          error=v
      elif k == 'output_to_console':
          to_console=v
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    if verbosity > 1:
      print('Compiling with %s implementation...' % _libhfst.fst_type_to_string(type))
    xfstcomp = XfstCompiler(type)
    xfstcomp.setOutputToConsole(to_console)
    xfstcomp.setVerbosity(verbosity > 0)
    xfstcomp.set('quit-on-fail', quit_on_fail)
    if verbosity > 1:
      print('Opening xfst file %s...' % filename)
    f = open(filename, 'r', encoding='utf-8')
    data = f.read()
    f.close()
    if verbosity > 1:
      print('File closed...')

    retval=-1
    import sys
    from io import StringIO

    # check special case
    if isinstance(output, StringIO) and isinstance(error, StringIO) and output == error:
       retval =_libhfst.hfst_compile_xfst_to_string_one(xfstcomp, data)
       output.write(_libhfst.get_hfst_xfst_string_one())
    else:
       arg1 = ""
       arg2 = ""
       if output == None or output == sys.stdout:
          arg1 = "cout"
       if output == sys.stderr:
          arg1 == "cerr"
       if error == None or error == sys.stderr:
          arg2 = "cerr"
       if error == sys.stdout:
          arg2 == "cout"

       retval = _libhfst.hfst_compile_xfst(xfstcomp, data, arg1, arg2)

       if isinstance(output, StringIO):
          output.write(_libhfst.get_hfst_xfst_string_one())
       if isinstance(error, StringIO):
          error.write(_libhfst.get_hfst_xfst_string_two())

    if verbosity > 1:
      print('Parsed file with return value %i (0 indicating succesful parsing).' % retval)
    return retval

def compile_pmatch_file(filename):
    with open(filename, 'r') as myfile:
      data=myfile.read()
      myfile.close()
    defs = compile_pmatch_expression(data)
    return defs

def compile_lexc_file(filename, **kvargs):
    verbosity=0
    withflags=False
    alignstrings=False
    type = _libhfst.get_default_fst_type()
    output=None
    to_console=get_output_to_console()

    for k,v in kvargs.items():
      if k == 'verbosity':
        verbosity=v
      elif k == 'with_flags':
        if v == True:
          withflags = v
      elif k == 'align_strings':
          alignstrings = v
      elif k == 'output':
          output=v
      elif k == 'output_to_console':
          to_console=v
      else:
        print('Warning: ignoring unknown argument %s.' % (k))

    lexccomp = LexcCompiler(type, withflags, alignstrings)
    lexccomp.setVerbosity(verbosity)
    lexccomp.setOutputToConsole(to_console)

    retval=-1
    import sys
    if output == None:
       retval = _libhfst.hfst_compile_lexc(lexccomp, filename, "")
    elif output == sys.stdout:
       retval = _libhfst.hfst_compile_lexc(lexccomp, filename, "cout")
    elif output == sys.stderr:
       retval = _libhfst.hfst_compile_lexc(lexccomp, filename, "cerr")
    else:
       retval = _libhfst.hfst_compile_lexc(lexccomp, filename, "")
       output.write(_libhfst.get_hfst_lexc_output())

    return retval

# internal function
def is_weighted_word(arg):
    if isinstance(arg, tuple) and len(arg) == 2 and isinstance(arg[0], str) and isinstance(arg[1], (int, float)):
       return True
    return False

# internal function
def check_word(arg):
    if len(arg) == 0:
       raise RuntimeError('Empty word.')
    return arg

def fsa(arg):
    deftok = HfstTokenizer()
    retval = HfstBasicTransducer()
    if isinstance(arg, str):
       retval.disjunct(deftok.tokenize(check_word(arg)), 0)
    elif is_weighted_word(arg):
       retval.disjunct(deftok.tokenize(check_word(arg[0])), arg[1])
    elif isinstance(arg, tuple) or isinstance(arg, list):
       for word in arg:
           if is_weighted_word(word):
              retval.disjunct(deftok.tokenize(check_word(word[0])), word[1])
           elif isinstance(word, str):
              retval.disjunct(deftok.tokenize(check_word(word)), 0)
           else:
              raise RuntimeError('Tuple/list element not a string or tuple of string and weight.')           
    else:
       raise RuntimeError('Not a string or tuple/list of strings.')
    return HfstTransducer(retval, _libhfst.get_default_fst_type())

def fst(arg):
    if isinstance(arg, dict):
       retval = regex('[0-0]') # empty transducer
       for input, output in arg.items():
           if not isinstance(input, str):
              raise RuntimeError('Key not a string.')
           left = fsa(input)
           right = 0
           if isinstance(output, str):
              right = fsa(output)
           elif isinstance(output, list) or isinstance(output, tuple):
              right = fsa(output)
           else:
              raise RuntimeError('Value not a string or tuple/list of strings.')
           left.cross_product(right)
           retval.disjunct(left)
       return retval
    return fsa(arg)

def tokenized_fst(arg, weight=0):
    retval = HfstBasicTransducer()
    state = 0 
    if isinstance(arg, list) or isinstance(arg, tuple):
       for token in arg:
           if isinstance(token, str):
              new_state = retval.add_state()
              retval.add_transition(state, new_state, token, token, 0)
              state = new_state
           elif isinstance(token, list) or isinstance(token, tuple):
              if len(token) == 2:
                 new_state = retval.add_state()
                 retval.add_transition(state, new_state, token[0], token[1], 0)
                 state = new_state
              elif len(token) == 1:
                 new_state = retval.add_state()
                 retval.add_transition(state, new_state, token, token, 0)
                 state = new_state
              else:
                 raise RuntimeError('Symbol or symbol pair must be given.')
       retval.set_final_weight(state, weight)
       return HfstTransducer(retval, _libhfst.get_default_fst_type())
    else:
       raise RuntimeError('Argument must be a list or a tuple')

def empty_fst():
    return regex('[0-0]')

def epsilon_fst(weight=0):
    return regex('[0]::' + str(weight))

def concatenate(transducers):
    retval = epsilon_fst()
    for tr in transducers:
      retval.concatenate(tr)
    retval.minimize()
    return retval

def disjunct(transducers):
    retval = empty_fst()
    for tr in transducers:
      retval.disjunct(tr)
    retval.minimize()
    return retval

def intersect(transducers):
    retval = None
    for tr in transducers:
      if retval == None:
        retval = HfstTransducer(tr)
      else:
        retval.intersect(tr)
    retval.minimize()
    return retval

%}
