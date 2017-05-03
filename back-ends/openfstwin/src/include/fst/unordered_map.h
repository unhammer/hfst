#ifdef _MSC_VER //Added  Paul Dixon
        #include <unordered_map>
#ifdef NO_CPLUSPLUS_11
		using std::tr1::unordered_map;
#else
        using std::unordered_map;
#endif
#else
        #include <tr1/unordered_map>
        using std::tr1::unordered_map;
#endif
