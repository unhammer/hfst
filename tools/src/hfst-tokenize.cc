//! @file hfst-tokenize.cc
//!
//! @brief A demo of a replacement for hfst-proc using pmatch
//!
//! @author HFST Team

//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, version 3 of the License.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

#ifdef HAVE_CONFIG_H
#  include <config.h>
#endif


#include <iostream>
#include <fstream>
#include <iterator>

#include <vector>
#include <map>
#include <string>
#include <set>

using std::string;
using std::vector;
using std::pair;

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <getopt.h>
#include <math.h>
#include <errno.h>

#include "hfst-commandline.h"
#include "hfst-program-options.h"
#include "hfst-tool-metadata.h"
#include "implementations/optimized-lookup/pmatch.h"
#include "parsers/pmatch_utils.h"
#include "HfstExceptionDefs.h"
#include "HfstDataTypes.h"
#include "HfstInputStream.h"
#include "implementations/ConvertTransducerFormat.h"

using hfst::HfstTransducer;

#include "inc/globals-common.h"
#include "inc/globals-unary.h"

static bool blankline_separated = true;
static bool keep_newlines = false;
static bool print_all = false;
static bool print_weights = false;
static bool tokenize_multichar = false;
static string tag_separator = "+"; // + and # are hardcoded in cg-conv at least
static string subreading_separator = "#";
static string wtag = "W"; // TODO: cg-conv has an argument --wtag, allow changing here as well?
static double time_cutoff = 0.0;
static int max_weight_classes = std::numeric_limits<int>::max();
std::string tokenizer_filename;
static hfst::ImplementationType default_format = hfst::TROPICAL_OPENFST_TYPE;
enum OutputFormat {
    tokenize,
    xerox,
    cg,
    finnpos,
    gtd
};
OutputFormat output_format = tokenize;

using hfst_ol::Location;
using hfst_ol::LocationVector;
using hfst_ol::LocationVectorVector;

void
print_usage()
{
    // c.f. http://www.gnu.org/prep/standards/standards.html#g_t_002d_002dhelp
    fprintf(message_out, "Usage: %s [--segment | --xerox | --cg | --gtd] [OPTIONS...] RULESET\n"
            "perform matching/lookup on text streams\n"
            "\n", program_name);
    print_common_program_options(message_out);
    fprintf(message_out,
            "  -n, --newline            Newline as input separator (default is blank line)\n"
            "  -a, --print-all          Print nonmatching text\n"
            "  -w, --print-weight       Print weights\n"
            "  -m, --tokenize-multichar Tokenize multicharacter symbols\n"
            "                           (by default only one utf-8 character is tokenized at a time\n"
            "                           regardless of what is present in the alphabet)\n"
            "  -tS, --time-cutoff=S     Limit search after having used S seconds per input\n"
            "  -lN, --weight-classes=N  Output no more than N best weight classes\n"
            "                           (where analyses with equal weight constitute a class\n"
            "  -z, --segment            Segmenting / tokenization mode (default)\n"
            "  -x, --xerox              Xerox output\n"
            "  -c, --cg                 Constraint Grammar output\n"
            "  -g, --gtd                Giellatekno/Divvun CG output (implies -l2)\n"
            "  -f, --finnpos            FinnPos output\n");
    fprintf(message_out,
            "Use standard streams for input and output (for now).\n"
            "\n"
        );

    print_report_bugs();
    fprintf(message_out, "\n");
    print_more_info();
    fprintf(message_out, "\n");
}

void print_no_output(std::string const & input, std::ostream & outstream)
{
    if (output_format == tokenize) {
        outstream << input;
    } else if (output_format == xerox) {
        outstream << input << "\t" << input << "+?";
    } else if (output_format == cg || output_format == gtd) {
	    outstream << "\"<" << input << ">\"" << std::endl << "\t\"" << input << "\" ?";
    }
//    std::cerr << "from print_no_output\n";
    outstream << "\n\n";
}

void print_escaping_newlines(std::string const & str, std::ostream & outstream)
{
    // TODO: inline?
    size_t i = 0, j = 0;
    while((j = str.find("\n", i)) != std::string::npos) {
        outstream << str.substr(i, j-i) << "\\n";
        i = j+1;
    }
    outstream << str.substr(i, j-i);
}

void print_nonmatching_sequence(std::string const & str, std::ostream & outstream)
{
    if (output_format == tokenize) {
        outstream << str;
    } else if (output_format == xerox) {
        outstream << str << "\t" << str << "+?";
    } else if (output_format == cg) {
        outstream << "\"<" << str << ">\"" << std::endl << "\t\"" << str << "\" ?";
    } else if (output_format == gtd) {
        outstream << ":";
        print_escaping_newlines(str, outstream);
    } else if (output_format == finnpos) {
        outstream << str << "\t_\t_\t_\t_";
    }
//    std::cerr << "from print_nonmatching_sequence\n";
    outstream << "\n";
}

hfst_ol::PmatchContainer make_naive_tokenizer(HfstTransducer & dictionary)
{
    HfstTransducer * word_boundary = hfst::pmatch::PmatchUtilityTransducers::
        make_latin1_whitespace_acceptor(default_format);
    HfstTransducer * punctuation = hfst::pmatch::PmatchUtilityTransducers::
        make_latin1_punct_acceptor(default_format);
    word_boundary->disjunct(*punctuation);
    HfstTransducer * others = hfst::pmatch::make_exc_list(word_boundary,
                                                          default_format);
    others->repeat_plus();
    // make the default token less likely than any dictionary token
    others->set_final_weights(std::numeric_limits<float>::max());
    HfstTransducer * word_boundary_list = hfst::pmatch::make_list(
        word_boundary, default_format);
    // @BOUNDARY@ is pmatch's special input boundary marker
    word_boundary_list->disjunct(HfstTransducer("@BOUNDARY@", default_format));
    delete word_boundary; delete punctuation;
    HfstTransducer * left_context = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::LC_ENTRY_SYMBOL, default_format);
    HfstTransducer * right_context = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::RC_ENTRY_SYMBOL, default_format);
    left_context->concatenate(*word_boundary_list);
    right_context->concatenate(*word_boundary_list);
    delete word_boundary_list;
    HfstTransducer * left_context_exit = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::LC_EXIT_SYMBOL, default_format);
    HfstTransducer * right_context_exit = new HfstTransducer(
        hfst::internal_epsilon, hfst::pmatch::RC_EXIT_SYMBOL, default_format);
    left_context->concatenate(*left_context_exit);
    right_context->concatenate(*right_context_exit);
    delete left_context_exit; delete right_context_exit;
    std::string dict_name = dictionary.get_name();
    if (dict_name == "") {
        dict_name = "unknown_pmatch_tokenized_dict";
        dictionary.set_name(dict_name);
    }
    HfstTransducer dict_ins_arc(hfst::pmatch::get_Ins_transition(dict_name.c_str()), default_format);
    // We now make the center of the tokenizer
    others->disjunct(dict_ins_arc);
    // And combine it with the context conditions
    left_context->concatenate(*others);
    left_context->concatenate(*right_context);
    delete others; delete right_context;
    // Because there are context conditions we need delimiter markers
    HfstTransducer * tokenizer = hfst::pmatch::add_pmatch_delimiters(left_context);
    tokenizer->set_name("TOP");
    tokenizer->minimize();
    // Convert the dictionary to olw if it wasn't already
    dictionary.convert(hfst::HFST_OLW_TYPE);
    // Get the alphabets
    std::set<std::string> dict_syms = dictionary.get_alphabet();
    std::set<std::string> tokenizer_syms = tokenizer->get_alphabet();
    std::vector<std::string> tokenizer_minus_dict;
    // What to add to the dictionary
    std::set_difference(tokenizer_syms.begin(), tokenizer_syms.end(),
                        dict_syms.begin(), dict_syms.end(),
                        std::inserter(tokenizer_minus_dict, tokenizer_minus_dict.begin()));
    for (std::vector<std::string>::const_iterator it = tokenizer_minus_dict.begin();
         it != tokenizer_minus_dict.end(); ++it) {
        dictionary.insert_to_alphabet(*it);
    }
    hfst::HfstBasicTransducer * tokenizer_basic = hfst::implementations::ConversionFunctions::
        hfst_transducer_to_hfst_basic_transducer(*tokenizer);
    hfst_ol::Transducer * tokenizer_ol = hfst::implementations::ConversionFunctions::
        hfst_basic_transducer_to_hfst_ol(tokenizer_basic,
                                         true, // weighted
                                         "", // no special options
                                         &dictionary); // harmonize with the dictionary
    delete tokenizer_basic;
    hfst_ol::PmatchContainer retval(tokenizer_ol);
    hfst_ol::Transducer * dict_backend = hfst::implementations::ConversionFunctions::
        hfst_transducer_to_hfst_ol(&dictionary);
    retval.add_rtn(dict_backend, dict_name);
    delete tokenizer_ol;
    return retval;
}

/**
 * Keep only the N best weight classes
 */
const LocationVector keep_n_best_weight(const int N, LocationVector const & locations)
{
    int classes_found = -1;
    hfst_ol::Weight last_weight_class = 0.0;
    LocationVector goodweight;
    for (LocationVector::const_iterator it = locations.begin();
         it != locations.end(); ++it) {
        hfst_ol::Weight current_weight = it->weight;
        if (classes_found == -1) // we're just starting
        {
            classes_found = 1;
            last_weight_class = current_weight;
        }
        else if (last_weight_class != current_weight)
        {
            last_weight_class = current_weight;
            ++classes_found;
        }
        if (classes_found > N)
        {
            break;
        }
        else {
            goodweight.push_back(*it);
        }
    }
    return goodweight;
}

/**
 * Return empty string if it wasn't a tag, otherwise the tag without the initial/final +
 */
const std::string as_cg_tag(const std::string & str) {
    size_t len = str.size();
    if(len > 1) {
        if (str.at(0) == '+') {
            return str.substr(1);
        }
        else if(str.at(len - 1) == '+') {
            return str.substr(0, len - 1);
        }
    }
    return "";
}

void print_cg_subreading(std::string const & indent,
                         hfst::StringVector::const_iterator & out_beg,
                         hfst::StringVector::const_iterator & out_end,
                         hfst_ol::Weight const & weight,
                         hfst::StringVector::const_iterator & in_beg,
                         hfst::StringVector::const_iterator & in_end,
                         std::ostream & outstream)
{
    outstream << indent;
    bool in_lemma = false;
    bool want_spc = false;
    for(hfst::StringVector::const_iterator it = out_beg;
        it != out_end; ++it) {
        const std::string & tag = as_cg_tag(*it);
        if(in_lemma) {
            if(tag.empty()) {
                outstream << (*it);
            }
            else {
                in_lemma = false;
                outstream << "\" " << tag;
                want_spc = true;
            }
        }
        else {
            if(want_spc) {
                outstream << " ";
            }
            if(tag.empty()) {
                in_lemma = true;
                outstream << "\"" << (*it);
            }
            else {
                outstream << tag;
                want_spc = true;
            }
        }
    }
    if(in_lemma) {
        outstream << "\"";
    }

    if (print_weights) {
        outstream << " <" << wtag << ":" << weight << ">";
    }
    if (in_beg != in_end) {
        std::ostringstream form;
        std::copy(in_beg, in_end, std::ostream_iterator<std::string>(form, ""));
        outstream << " \"<" << form.str() << ">\"";
    }
    outstream << std::endl;
}

void print_location_vector_gtd(hfst_ol::PmatchContainer & container,
                               LocationVector const & locations,
                               std::ostream & outstream)
{
    outstream << "\"<" << locations.at(0).input << ">\"" << std::endl;
    if(locations.size() == 1 && locations.at(0).output.empty()) {
        // Treat empty analyses as unknown-but-tokenised:
        outstream << "\t\"" << locations.at(0).input << "\" ?" << std::endl;
    }
    else {
        std::set<size_t> backtrack;
        for (LocationVector::const_iterator loc_it = locations.begin();
             loc_it != locations.end(); ++loc_it) {
            if(loc_it->output.empty()) {
                continue;
            }
            std::string indent = "\t";
            hfst::StringVector::const_iterator
                out_beg = loc_it->output_symbol_strings.begin(),
                out_end = loc_it->output_symbol_strings.end(),
                in_beg = loc_it->input_symbol_strings.end(), // beg=end: don't print input unless we have to
                in_end = loc_it->input_symbol_strings.end();
            size_t part = loc_it->input_parts.size();
            while(true) {
                std::string inpart;
                bool sub_found = false;
                size_t out_part = part > 0 ? loc_it->output_parts.at(part-1) : 0;
                while(out_part > 0 && loc_it->output_symbol_strings.at(out_part-1) == "@PMATCH_BACKTRACK@") {
                    backtrack.insert(part);
                    --part;
                    out_part = part > 0 ? loc_it->output_parts.at(part-1) : 0;
                }
                for(hfst::StringVector::const_iterator it = out_end-1;
                    it > loc_it->output_symbol_strings.begin() + out_part;
                    --it) {
                    if(subreading_separator.compare(*it) == 0) {
                        // Found a sub-reading mark
                        out_beg = ++it;
                        sub_found = true;
                        break;
                    }
                }
                if(!sub_found) {
                    if(out_part > 0) {
                        // Found an input mark
                        out_beg = loc_it->output_symbol_strings.begin() + out_part;
                        in_beg = loc_it->input_symbol_strings.begin() + loc_it->input_parts.at(part-1);
                        --part;
                    }
                    else {
                        // No remaining sub-marks or input-marks to the left
                        out_beg = loc_it->output_symbol_strings.begin();
                        if(in_end != loc_it->input_symbol_strings.end()) {
                            // We've seen at least one input-mark, so we need to output the remaining input as well
                            in_beg = loc_it->input_symbol_strings.begin();
                        }
                    }
                }
                print_cg_subreading(indent,
                                    out_beg,
                                    out_end,
                                    loc_it->weight,
                                    in_beg,
                                    in_end,
                                    outstream);
                if(out_beg == loc_it->output_symbol_strings.begin()) {
                    break;
                }
                else {
                    indent += "\t";
                    out_end = out_beg;
                    in_end = in_beg;
                    if(sub_found) {
                        out_end--; // skip the subreading separator symbol
                    }
                }
            }
        }
        if(!backtrack.empty()) {
            backtrack.insert(1);
            Location loc_in = locations.at(0);
            LocationVectorVector locs_rebuilt = LocationVectorVector(backtrack.size());
            size_t i_b = 0;
            for(std::set<size_t>::const_iterator it = backtrack.begin();
                it != backtrack.end(); ++it, ++i_b) {
                hfst::StringVector::const_iterator
                    in_beg = loc_in.input_symbol_strings.begin() + loc_in.input_parts.at((*it)-1),
                    in_end = loc_in.input_symbol_strings.end();
                if((*it) < loc_in.input_parts.size()) {
                    in_end = loc_in.input_symbol_strings.begin() + loc_in.input_parts.at((*it));
                }
                while((in_end-1)->find_first_not_of(' ') == std::string::npos) { // rtrim
                    --in_end;
                }
                std::ostringstream ssform;
                std::copy(in_beg, in_end, std::ostream_iterator<std::string>(ssform, ""));
                std::string form = ssform.str();
                LocationVectorVector locations = container.locate(form, time_cutoff);
                if(locations.size() != 1) {
                    outstream << "locations.size() != 1"<<std::endl;
                }
                for(LocationVectorVector::const_iterator it = locations.begin();
                    it != locations.end(); ++it) {
                    if (it->empty()
                        || (it->size() == 1 && it->at(0).output.compare("@_NONMATCHING_@") == 0)
                        // keep only those that cover the full form
                        || it->at(0).length != form.length()) {
                        continue;
                    }
                    LocationVector loc = keep_n_best_weight(max_weight_classes, *it);
                    for (LocationVector::const_iterator loc_it = loc.begin();
                         loc_it != loc.end(); ++loc_it) {
                        if(!loc_it->output.empty()
                            &&
                           // TODO: why aren't the <W:inf> excluded earlier?
                           loc_it->weight < std::numeric_limits<float>::max()) {
                            locs_rebuilt.at(i_b).push_back(*loc_it);
                        }
                    }
                }
            }
            size_t depth = 0;
            std::vector<std::ostringstream> out(locs_rebuilt.size());
            LocationVectorVector todo = (LocationVectorVector){locs_rebuilt.at(depth)};
            while(!todo.empty() && !todo.back().empty()) {
                std::string indent = std::string(depth+1, '\t');
                Location cur = todo.back().back();
                todo.back().pop_back();
                hfst::StringVector::const_iterator
                    out_beg = cur.output_symbol_strings.begin(),
                    out_end = cur.output_symbol_strings.end(),
                    in_beg = cur.input_symbol_strings.end(), // beg=end: don't print input unless we have to
                    in_end = cur.input_symbol_strings.end();
                size_t part = cur.input_parts.size();
                out.at(depth) = std::ostringstream();
                while(true) {
                    std::string inpart;
                    bool sub_found = false;
                    size_t out_part = part > 0 ? cur.output_parts.at(part-1) : 0;
                    for(hfst::StringVector::const_iterator it = out_end-1;
                        it > cur.output_symbol_strings.begin() + out_part;
                        --it) {
                        if(subreading_separator.compare(*it) == 0) {
                            // Found a sub-reading mark
                            out_beg = ++it;
                            sub_found = true;
                            break;
                        }
                    }
                    if(!sub_found) {
                        if(out_part > 0) {
                            // Found an input mark
                            out_beg = cur.output_symbol_strings.begin() + out_part;
                            in_beg = cur.input_symbol_strings.begin() + cur.input_parts.at(part-1);
                            --part;
                        }
                        else {
                            // No remaining sub-marks or input-marks to the left
                            out_beg = cur.output_symbol_strings.begin();
                            if(in_end != cur.input_symbol_strings.end()) {
                                // We've seen at least one input-mark, so we need to output the remaining input as well
                                in_beg = cur.input_symbol_strings.begin();
                            }
                        }
                    }
                    print_cg_subreading(indent,
                                        out_beg,
                                        out_end,
                                        cur.weight,
                                        in_beg,
                                        in_end,
                                        out.at(depth));
                    if(out_beg == cur.output_symbol_strings.begin()) {
                        break;
                    }
                    else {
                        indent += "\t";
                        out_end = out_beg;
                        in_end = in_beg;
                        if(sub_found) {
                            out_end--; // skip the subreading separator symbol
                        }
                    }
                }
                if(depth == locs_rebuilt.size()-1) {
                    for(std::vector<std::ostringstream>::const_iterator it = out.begin();
                        it != out.end();
                        it++) {
                        outstream << it->str();
                    }
                }
                if(depth < locs_rebuilt.size()-1) {
                    ++depth;
                    todo.push_back(locs_rebuilt.at(depth));
                }
                else if(todo.back().empty()){
                    depth--;
                    todo.pop_back();
                }
            }
        }
    }
}

void print_location_vector(hfst_ol::PmatchContainer & container,
                           LocationVector const & locations,
                           std::ostream & outstream)
{
    if (output_format == tokenize && locations.size() != 0) {
        outstream << locations.at(0).input;
        if (print_weights) {
            outstream << "\t" << locations.at(0).weight;
        }
        outstream << std::endl << std::endl;
    } else if (output_format == cg && locations.size() != 0) {
        // Print the cg cohort header
        outstream << "\"<" << locations.at(0).input << ">\"" << std::endl;
        for (LocationVector::const_iterator loc_it = locations.begin();
             loc_it != locations.end(); ++loc_it) {
            // For the most common case, eg. analysis strings that begin with the original input,
            // we try to do what cg tools expect and surround the original input with double quotes.
            // Otherwise we omit the double quotes and assume the rule writer knows what he's doing.
            if (loc_it->output.find(loc_it->input) == 0) {
                // The nice case obtains
                outstream << "\t\"" << loc_it->input << "\"" <<
                    loc_it->output.substr(loc_it->input.size(), std::string::npos);
            } else {
                outstream << "\t" << loc_it->output;
            }
            if (print_weights) {
                outstream << "\t" << loc_it->weight;
            }
            outstream << std::endl;
        }
        outstream << std::endl;
    } else if (output_format == gtd && locations.size() != 0) {
        print_location_vector_gtd(container, locations, outstream);
    } else if (output_format == xerox) {
        for (LocationVector::const_iterator loc_it = locations.begin();
             loc_it != locations.end(); ++loc_it) {
            outstream << loc_it->input << "\t" << loc_it->output;
            if (print_weights) {
                outstream << "\t" << loc_it->weight;
            }
            outstream << std::endl;
        }
        outstream << std::endl;
    } else if (output_format == finnpos) {
        std::set<std::string> tags;
        std::set<std::string> lemmas;
            for (LocationVector::const_iterator loc_it = locations.begin();
                 loc_it != locations.end(); ++loc_it) {
                // Assume the last space is where the tags begin
                size_t tags_start_at = loc_it->output.find_last_of(" ");
                if (tags_start_at != std::string::npos) {
                    std::string lemma = loc_it->output.substr(0, tags_start_at);
                    if (lemma.find_first_of(" ") == std::string::npos) {
                        // can't have spaces in lemmas
                        lemmas.insert(lemma);
                    }
                    std::string tag = loc_it->output.substr(tags_start_at + 1);
                    if (tag.find_first_of(" ") == std::string::npos) {
                        // or tags
                        tags.insert(tag);
                    }
                }
            }
        outstream << locations.at(0).input << "\t_\t";
        // the input and a blank for features
        if (lemmas.empty()) {
            outstream << "_";
        } else {
            std::string accumulator;
            for (std::set<std::string>::const_iterator it = lemmas.begin();
                 it != lemmas.end(); ++it) {
                accumulator.append(*it);
                accumulator.append(" ");
            }
            outstream << accumulator.substr(0, accumulator.size() - 1);
        }
        outstream << "\t";
        if (tags.empty()) {
            outstream << "_";
        } else {
            std::string accumulator;
            for (std::set<std::string>::const_iterator it = tags.begin();
                 it != tags.end(); ++it) {
                accumulator.append(*it);
                accumulator.append(" ");
            }
            outstream << accumulator.substr(0, accumulator.size() - 1);
        }
        outstream << "\t_" << std::endl;
    }
//    std::cerr << "from print_location_vector\n";
}

void match_and_print(hfst_ol::PmatchContainer & container,
                     std::ostream & outstream,
                     std::string & input_text)
{
    if (input_text.size() > 0 && input_text.at(input_text.size() - 1) == '\n') {
        // Remove final newline
        input_text.erase(input_text.size() -1, 1);
    }
    LocationVectorVector locations = container.locate(input_text, time_cutoff);
    if (locations.size() == 0 && print_all) {
        print_no_output(input_text, outstream);
    }
    for(LocationVectorVector::const_iterator it = locations.begin();
        it != locations.end(); ++it) {
        if ((it->size() == 1 && it->at(0).output.compare("@_NONMATCHING_@") == 0)) {
            if (print_all) {
                print_nonmatching_sequence(it->at(0).input, outstream);
            }
            continue;
            // All nonmatching cases have been handled
        }
        if(max_weight_classes < std::numeric_limits<int>::max()) {
            print_location_vector(container,
                                  keep_n_best_weight(max_weight_classes, *it),
                                  outstream);
        }
        else {
            print_location_vector(container, *it, outstream);
        }
    }
    if (output_format == finnpos) {
        outstream << std::endl;
    }
}


int process_input(hfst_ol::PmatchContainer & container,
                  std::ostream & outstream)
{
    std::string input_text;
    char * line = NULL;
    size_t len = 0;
    if(blankline_separated) {
        while (hfst_getline(&line, &len, inputfile) > 0) {
            if (line[0] == '\n') {
                match_and_print(container, outstream, input_text);
                input_text.clear();
            } else {
                input_text.append(line);
            }
            free(line);
            line = NULL;
        }
        if (!input_text.empty()) {
            match_and_print(container, outstream, input_text);
        }
    }
    else {
        // newline or non-separated
        while (hfst_getline(&line, &len, inputfile) > 0) {
            input_text = line;
            if(keep_newlines) {
                input_text += "\n";
            }
            match_and_print(container, outstream, input_text);
            free(line);
            line = NULL;
        }
    }

    return EXIT_SUCCESS;
}

int parse_options(int argc, char** argv)
{
    extend_options_getenv(&argc, &argv);
    // use of this function requires options are settable on global scope
    while (true)
    {
        static const struct option long_options[] =
            {
                HFST_GETOPT_COMMON_LONG,
                {"newline", no_argument, 0, 'n'},
                {"keep-newline", no_argument, 0, 'k'},
                {"print-all", no_argument, 0, 'a'},
                {"print-weights", no_argument, 0, 'w'},
                {"tokenize-multichar", no_argument, 0, 'm'},
                {"time-cutoff", required_argument, 0, 't'},
                {"weight-classes", required_argument, 0, 'l'},
                {"segment", no_argument, 0, 'z'},
                {"xerox", no_argument, 0, 'x'},
                {"cg", no_argument, 0, 'c'},
                {"gtd", no_argument, 0, 'g'},
                {"finnpos", no_argument, 0, 'f'},
                {0,0,0,0}
            };
        int option_index = 0;
        char c = getopt_long(argc, argv, HFST_GETOPT_COMMON_SHORT "nkawmt:l:zxcgf",
                             long_options, &option_index);
        if (-1 == c)
        {
            break;
        }


        switch (c)
        {
#include "inc/getopt-cases-common.h"
        case 'k':
            keep_newlines = true;
            blankline_separated = false;
            break;
        case 'n':
            blankline_separated = false;
            break;
        case 'a':
            print_all = true;
            break;
        case 'w':
            print_weights = true;
            break;
        case 'm':
            tokenize_multichar = true;
            break;
        case 't':
            time_cutoff = atof(optarg);
            if (time_cutoff < 0.0)
            {
                std::cerr << "Invalid argument for --time-cutoff\n";
                return EXIT_FAILURE;
            }
            break;
        case 'l':
            max_weight_classes = atoi(optarg);
            if (max_weight_classes < 1)
            {
                std::cerr << "Invalid or no argument --weight-classes count\n";
                return EXIT_FAILURE;
            }
            break;
        case 'z':
            output_format = tokenize;
            break;
        case 'x':
            output_format = xerox;
            break;
        case 'c':
            output_format = cg;
            break;
        case 'g':
            output_format = gtd;
            print_weights = true;
            print_all = true;
            keep_newlines = true;
            blankline_separated = false;
            if(max_weight_classes == std::numeric_limits<int>::max()) {
                max_weight_classes = 2;
            }
            break;
        case 'f':
            output_format = finnpos;
            break;
#include "inc/getopt-cases-error.h"
        }



    }

//            if (!inputNamed)
//        {
//            inputfile = stdin;
//            inputfilename = hfst_strdup("<stdin>");
//        }

        // no more options, we should now be at the input filename
        if ( (optind + 1) < argc)
        {
            std::cerr << "More than one input file given\n";
            return EXIT_FAILURE;
        }
        else if ( (optind + 1) == argc)
        {
            tokenizer_filename = argv[(optind)];
            return EXIT_CONTINUE;
        }
        else
        {
            std::cerr << "No input file given\n";
            return EXIT_FAILURE;
        }


#include "inc/check-params-common.h"



    return EXIT_FAILURE;
}

bool first_transducer_is_called_TOP(const HfstTransducer & dictionary)
{
    return dictionary.get_name() == "TOP";
}

int main(int argc, char ** argv)
{
    hfst_set_program_name(argv[0], "0.1", "HfstTokenize");
    hfst_setlocale();
    int retval = parse_options(argc, argv);
    if (retval != EXIT_CONTINUE) {
        return retval;
    }
    std::ifstream instream(tokenizer_filename.c_str(),
                           std::ifstream::binary);
    if (!instream.good()) {
        std::cerr << "Could not open file " << tokenizer_filename << std::endl;
        return EXIT_FAILURE;
    }
    try {
        hfst::HfstInputStream is(tokenizer_filename);
        HfstTransducer dictionary(is);
        if (first_transducer_is_called_TOP(dictionary)) {
            instream.seekg(0);
            instream.clear();
            hfst_ol::PmatchContainer container(instream);
            container.set_verbose(verbose);
            container.set_single_codepoint_tokenization(!tokenize_multichar);
            return process_input(container, std::cout);
        } else {
            instream.close();
            hfst_ol::PmatchContainer container = make_naive_tokenizer(dictionary);
            container.set_verbose(verbose);
            container.set_single_codepoint_tokenization(!tokenize_multichar);
            return process_input(container, std::cout);
        }
    } catch(HfstException & e) {
        std::cerr << "The archive in " << tokenizer_filename << " doesn't look right."
            "\nDid you make it with hfst-pmatch2fst or make sure it's in weighted optimized-lookup format?\n";
        return 1;
    }

//     if (outfile != stdout) {
//         std::filebuf fb;
// fb.open(outfilename, std::ios::out);
// std::ostream outstream(&fb);
// return process_input(container, outstream);
// fb.close();
//     } else {

}
