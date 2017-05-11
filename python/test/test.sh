
PYTHON="python3"
PYTHONPATH=""
VERBOSE="false"

if [ "$1" = "--help" -o "$1" = "-h" ]; then
    echo ""
    echo "Run all tests in this folder."
    echo ""
    echo "Usage: test.sh [--python PYTHON] [--pythonpath PATH] [--verbose]"
    echo ""
    echo "PYTHON:    the python to be used for testing, defaults to 'python3'"
    echo "PATH:      full path to insert to sys.path before running each test"
    echo "--verbose: show output of tests"
    echo ""
    exit 0
fi

python="false"
pythonpath="false"
for arg in $@;
do
    if [ "$python" = "true" ]; then
	PYTHON=$arg
	python="false"
    elif [ "$pythonpath" = "true" ]; then
	PYTHONPATH=$arg
	pythonpath="false"
    elif [ "$arg" = "--python" ]; then
	python="true"
    elif [ "$arg" = "--pythonpath" ]; then
	pythonpath="true"
    elif [ "$arg" = "--verbose" ]; then
	VERBOSE="true"
    else
	echo "warning: skipping unknown argument '"$arg"'";
    fi
done

for file in test_dir_hfst.py test_dir_hfst_exceptions.py test_dir_hfst_sfst_rules.py \
    test_tokenizer.py test_exceptions.py test_xre.py \
    test_read_att_transducer.py test_prolog.py \
    test_att_reader.py test_prolog_reader.py \
    test_pmatch.py test_xerox_rules.py \
    test_hfst.py test_examples.py test_twolc.py;
do
    if [ "$VERBOSE" = "true" ]; then
	$PYTHON $file $PYTHONPATH
    else
	$PYTHON $file $PYTHONPATH 2> /dev/null > /dev/null
    fi
    if [ "$?" = "0" ]; then
        echo $file" passed"
    else
        echo $file" failed"
        exit 1
    fi
done

for format in sfst openfst foma;
do
    if ( $PYTHON test_streams_1.py $format $PYTHONPATH | $PYTHON test_streams_2.py $format $PYTHONPATH | $PYTHON test_streams_3.py $format $PYTHONPATH ); then
        echo "test_streams[1|2|3].py with "$format" format passed"
    elif [ "$?" = "77" ]; then
        echo "test_streams[1|2|3].py with "$format" format skipped"
    else
        echo "test_streams[1|2|3].py with "$format" format failed"
        exit 1
    fi
done

rm foo
rm foo_att_prolog
rm testfile3.att
rm testfile_.att
