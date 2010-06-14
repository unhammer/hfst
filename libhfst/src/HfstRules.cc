#include "HfstTransducer.h"

namespace hfst
{
  namespace rules
  {

    HfstTransducer & universal_fst(const StringPairSet &alphabet, ImplementationType type)
    {
      HfstTransducer retval(alphabet, type);
      retval.repeat_star();
      HfstTransducer &retval_ = retval;
      return retval_;
    }

    HfstTransducer & negation_fst(HfstTransducer &t, const StringPairSet &alphabet)
    {
      HfstTransducer retval = universal_fst(alphabet, t.get_type());
      retval.subtract(t);
      HfstTransducer &retval_ = retval;
      return retval_;
    }

    HfstTransducer & replace( HfstTransducer &t, ReplaceType repl_type, bool optional, StringPairSet &alphabet ) 
    {
      ImplementationType type = t.get_type();

      HfstTransducer t_proj(t);
      if (repl_type == REPL_UP)
	t_proj.input_project();
      if (repl_type == REPL_DOWN)
	t_proj.output_project();
      else
	throw hfst::exceptions::ImpossibleReplaceTypeException();

      // tc = ( .* t_proj .* )
      HfstTransducer tc = universal_fst(alphabet, type);
      tc.concatenate(t_proj);
      tc.concatenate(universal_fst(alphabet, type));
		     
      // tc_neg = ! ( .* t_proj .* )
      HfstTransducer tc_neg = negation_fst(tc, alphabet);

      // retval = ( tc_neg tc )* tc_neg
      HfstTransducer retval(tc_neg);
      retval.concatenate(tc);
      retval.repeat_star();
      retval.concatenate(tc_neg);

      if (optional)
	retval.disjunct(universal_fst(alphabet, type));

      HfstTransducer &retval_ = retval;
      return retval_;
    }

    HfstTransducer & replace_transducer(HfstTransducer &t, std::string lm, std::string rm, ReplaceType repl_type, StringPairSet &alphabet)
    {
      ImplementationType type = t.get_type();

      // tm = ( L (L >> (R >> t)) R )
      HfstTransducer tc(t);
      tc.insert_freely(StringPair(rm,rm));
      tc.insert_freely(StringPair(lm,lm));
      HfstTransducer tm(lm, type);
      HfstTransducer rmtr(rm,type);
      tm.concatenate(tc);
      tm.concatenate(rmtr);

      HfstTransducer &retval = replace(tm, repl_type, false, alphabet);
      return retval;
    }



    HfstTransducer & replace_context(HfstTransducer &t, std::string m1, std::string m2, StringPairSet &alphabet)
    {
      // ct = .* ( m1 >> ( m2 >> t ))  ||  !(.* m1)

      // m1 >> ( m2 >> t )
      HfstTransducer t_copy(t);
      t_copy.insert_freely(StringPair(m2,m2));
      t_copy.insert_freely(StringPair(m1,m1));
      // arg1 = .* ( m1 >> ( m2 >> t ))
      HfstTransducer arg1 = universal_fst(alphabet, t.get_type());
      arg1.concatenate(t_copy);

      // arg2 = !(.* m1)
      HfstTransducer m1_tr(m1, t.get_type());
      HfstTransducer arg2 = negation_fst(universal_fst(alphabet, t.get_type()).concatenate(m1_tr),
					 alphabet);

      // ct = .* ( m1 >> ( m2 >> t ))  ||  !(.* m1)
      HfstTransducer ct = arg1.compose(arg2);


      // mt = m2* m1 .*
      HfstTransducer mt(m2, t.get_type());
      mt.repeat_star();
      mt.concatenate(m1_tr);
      mt.concatenate(universal_fst(alphabet,t.get_type()));

      // !( (!ct mt) | (ct !mt) )

      // ct !mt
      HfstTransducer ct_neg_mt(ct);
      ct_neg_mt.concatenate(negation_fst(mt, alphabet));
      // !ct mt
      HfstTransducer neg_ct_mt = negation_fst(ct, alphabet).concatenate(mt) ;
      // disjunction
      HfstTransducer disj = neg_ct_mt.disjunct(ct_neg_mt);
      // negation
      HfstTransducer &retval = negation_fst(disj, alphabet); 
      return retval;
    }



    /* identical to  ![ .* l [a:. & !a:b] r .* ]  */
    HfstTransducer two_level_if(HfstTransducerPair &context, StringPairSet &mappings, StringPairSet &alphabet) 
    {
      if (context.first.get_type() != context.second.get_type())
	throw hfst::exceptions::TransducerTypeMismatchException();
      ImplementationType type = context.first.get_type();

      assert(context.first.get_type() != UNSPECIFIED_TYPE);
      assert(context.second.get_type() != ERROR_TYPE);
      assert(context.first.get_type() != UNSPECIFIED_TYPE);
      assert(context.second.get_type() != ERROR_TYPE);

      // calculate [ a:. ]
      StringPairSet input_to_any;
      for (StringPairSet::iterator it = mappings.begin(); it != mappings.end(); it++)
	{
	  for (StringPairSet::iterator alpha_it = alphabet.begin(); alpha_it != alphabet.end(); alpha_it++)
	    {
	      if (alpha_it->first == it->first)
		{
		  input_to_any.insert(StringPair(alpha_it->first, alpha_it->second));
		}
	    }
	}
      // center == [ a:. ]
      HfstTransducer center(input_to_any, type);

      // calculate [ .* - a:b ]
      HfstTransducer neg_mappings(alphabet, type);
      neg_mappings.repeat_star();
      HfstTransducer mappings_tr(mappings, type);
      neg_mappings.subtract(mappings_tr);

      // center == [ a:. & !a:b ]
      center.intersect(neg_mappings);

      // left context == [ .* l ]
      HfstTransducer left_context(alphabet, type);
      left_context.repeat_star();
      left_context.concatenate(context.first);

      // right_context == [ r .* ]
      HfstTransducer right_context(context.second);
      HfstTransducer universal(alphabet, type);
      universal.repeat_star();
      right_context.concatenate(universal);

      HfstTransducer inside(left_context.concatenate(center).concatenate(right_context));

      HfstTransducer retval(universal.subtract(inside));
      return retval;
    }


    // equivalent to !(!(.* l) a:b .* | .* a:b !(r .*))
    HfstTransducer two_level_only_if(HfstTransducerPair &context, StringPairSet &mappings, StringPairSet &alphabet) 
    { 
      if (context.first.get_type() != context.second.get_type())
	throw hfst::exceptions::TransducerTypeMismatchException();
      ImplementationType type = context.first.get_type();

      assert(context.first.get_type() != UNSPECIFIED_TYPE);
      assert(context.second.get_type() != ERROR_TYPE);
      assert(context.first.get_type() != UNSPECIFIED_TYPE);
      assert(context.second.get_type() != ERROR_TYPE);

      // center = a:b
      HfstTransducer center(mappings, type);

      // left_neg = !(.* l)
      HfstTransducer left(alphabet, type);
      left.repeat_star();
      left.concatenate(context.first);
      HfstTransducer left_neg(alphabet, type);
      left_neg.repeat_star();
      left_neg.subtract(left);

      // right_neg = !(r .*)
      HfstTransducer universal(alphabet, type);
      universal.repeat_star();
      HfstTransducer right(context.second);
      right.concatenate(universal);
      HfstTransducer right_neg(alphabet, type);
      right_neg.repeat_star();
      right_neg.subtract(right);

      // left_neg + center + universal  |  universal + center + right_neg
      HfstTransducer rule(left_neg);
      rule.concatenate(center);
      rule.concatenate(universal);
      HfstTransducer rule_right(universal);
      rule_right.concatenate(center);
      rule_right.concatenate(right_neg);
      rule.disjunct(rule_right);

      HfstTransducer rule_neg(alphabet, type);
      rule_neg.repeat_star();
      rule_neg.subtract(rule);

      return rule_neg;
    }

    HfstTransducer two_level_if_and_only_if(HfstTransducerPair &context, StringPairSet &mappings, StringPairSet &alphabet) 
    {
      HfstTransducer if_rule = two_level_if(context, mappings, alphabet);
      HfstTransducer only_if_rule = two_level_only_if(context, mappings, alphabet);
      return if_rule.intersect(only_if_rule);
    }

    HfstTransducer & replace_in_context(HfstTransducerPair &context, ReplaceType repl_type, HfstTransducer &t, bool optional, StringPairSet &alphabet)
    {
      // test that all transducers have the same type
      if (context.first.get_type() != context.second.get_type() != t.get_type())
	throw hfst::exceptions::TransducerTypeMismatchException();
      ImplementationType type = t.get_type();      

      // test that both context transducers are automata
      // this could be done more efficiently...
      HfstTransducer t1_proj(context.first);
      t1_proj.input_project();
      HfstTransducer t2_proj(context.second);
      t2_proj.input_project();
      if ( not HfstTransducer::are_equivalent(t1_proj, context.first) ||
	   not HfstTransducer::are_equivalent(t2_proj, context.second) )
	throw hfst::exceptions::ContextTransducersAreNotAutomataException();
      
      std::string leftm("@_LEFT_MARKER_@");
      std::string rightm("@_RIGHT_MARKER_@");
      std::string epsilon("@_EPSILON_SYMBOL_@");

      // Create the insert boundary transducer (.|<>:<L>|<>:<R>)*    
      HfstTransducer ibt(alphabet, type);
      HfstTransducer eps_to_leftm(epsilon, leftm, type);
      HfstTransducer eps_to_rightm(epsilon, rightm, type);
      ibt.disjunct(eps_to_leftm);
      ibt.disjunct(eps_to_rightm);
      ibt.repeat_star();

      // Create the remove boundary transducer (.|<L>:<>|<R>:<>)*    
      HfstTransducer rbt(alphabet, type);
      HfstTransducer leftm_to_eps(leftm, epsilon, type);
      HfstTransducer rightm_to_eps(rightm, epsilon, type);
      rbt.disjunct(leftm_to_eps);
      rbt.disjunct(rightm_to_eps);
      rbt.repeat_star();

      // Add the markers to the alphabet
      alphabet.insert(StringPair(leftm,leftm));
      alphabet.insert(StringPair(rightm,rightm));

      // Create the constrain boundary transducer !(.*<L><R>.*)
      HfstTransducer leftm_to_leftm(leftm, leftm, type);
      HfstTransducer rightm_to_rightm(rightm, rightm, type);
      HfstTransducer tmp = universal_fst(alphabet,type);
      tmp.concatenate(leftm_to_leftm);
      tmp.concatenate(rightm_to_rightm);
      tmp.concatenate(universal_fst(alphabet,type));
      HfstTransducer cbt = negation_fst(tmp, alphabet);

      throw hfst::exceptions::FunctionNotImplementedException();
    }


    HfstTransducer replace_up(HfstTransducerPair &context, HfstTransducer &mapping, bool optional, StringPairSet &alphabet) 
    { 
      return replace_in_context(context, REPL_UP, mapping, optional, alphabet);
    }

    HfstTransducer replace_down(HfstTransducerPair &context, HfstTransducer &mapping, bool optional, StringPairSet &alphabet) 
    { 
      return replace_in_context(context, REPL_DOWN, mapping, optional, alphabet);
    }

    HfstTransducer replace_right(HfstTransducerPair &context, HfstTransducer &mapping, bool optional, StringPairSet &alphabet) 
    { 
      return replace_in_context(context, REPL_RIGHT, mapping, optional, alphabet);
    }

    HfstTransducer replace_left(HfstTransducerPair &context, HfstTransducer &mapping, bool optional, StringPairSet &alphabet)
    { 
      return replace_in_context(context, REPL_LEFT, mapping, optional, alphabet);
    }

    HfstTransducer replace_up(HfstTransducer &mapping, bool optional, StringPairSet &alphabet)
    {
      return replace(mapping, REPL_UP, optional, alphabet);
    }

    HfstTransducer replace_down(HfstTransducer &mapping, bool optional, StringPairSet &alphabet)
    {
      return replace(mapping, REPL_DOWN, optional, alphabet);
    }


    HfstTransducer restriction(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer restriction_and_coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer surface_restriction(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer surface_coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer surface_restriction_and_coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer deep_restriction(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer deep_coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 
    HfstTransducer deep_restriction_and_coercion(HfstTransducerPairSet &contexts, HfstTransducer &mapping, StringPairSet &alphabet) 
    { throw hfst::exceptions::FunctionNotImplementedException(); } 

  }

}
