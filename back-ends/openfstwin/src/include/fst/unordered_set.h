#ifdef _MSC_VER //Added Paul Dixon
        #include <unordered_set>
#ifdef NO_CPLUSPLUS_11		
		using std::tr1::unordered_set;
#else
        using std::unordered_set;
#endif
#else
        #include <tr1/unordered_set>
        using std::tr1::unordered_set;
#endif
