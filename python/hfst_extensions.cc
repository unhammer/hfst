namespace hfst {

// *** Add default implementation type *** //

hfst::ImplementationType type = hfst::TROPICAL_OPENFST_TYPE;
void set_default_fst_type(hfst::ImplementationType t) { type = t; }
hfst::ImplementationType get_default_fst_type() { return type; }

std::string fst_type_to_string(hfst::ImplementationType t) { std::string retval = hfst::implementation_type_to_string(t); return retval; }

bool is_diacritic(const std::string & symbol) { return hfst::FdOperation::is_diacritic(symbol); }

HfstTransducer * copy_hfst_transducer(const hfst::HfstTransducer & t) { return new HfstTransducer(t); }
HfstTransducer * copy_hfst_transducer_from_basic_transducer(const hfst::implementations::HfstBasicTransducer & t) { return new HfstTransducer(t, type); }
HfstTransducer * copy_hfst_transducer_from_basic_transducer(const hfst::implementations::HfstBasicTransducer & t, hfst::ImplementationType impl) { return new HfstTransducer(t, impl); }

hfst::HfstOutputStream * create_hfst_output_stream(const std::string & filename, hfst::ImplementationType type, bool hfst_format)
{
        if (filename == "") { return new hfst::HfstOutputStream(type, hfst_format); }
        else { return new hfst::HfstOutputStream(filename, type, hfst_format); }
}

hfst_ol::PmatchContainer * create_pmatch_container(const std::string & filename)
{
    std::ifstream instream(filename.c_str(),
                           std::ifstream::binary);
    if (!instream.good()) {
        return NULL;
    }
    return new hfst_ol::PmatchContainer(instream);
}


hfst::HfstTransducer * read_att(hfst::HfstFile & f, std::string epsilon="@_EPSILON_SYMBOL_@")
{
      return new hfst::HfstTransducer(f.get_file(), type, epsilon);
}

hfst::HfstTransducer * read_prolog(hfst::HfstFile & f)
{
    unsigned int linecount = 0;
    hfst::implementations::HfstBasicTransducer fsm = hfst::implementations::HfstBasicTransducer::read_in_prolog_format(f.get_file(), linecount);
    return new hfst::HfstTransducer(fsm, hfst::type);
}

}