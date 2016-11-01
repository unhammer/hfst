
PYTHON="python3"
PYTHONPATH=""

if [ "$1" = "--python" ]; then
    PYTHON=$2
fi

if [ "$1" = "--pythonpath" ]; then
    PYTHONPATH=$2
fi

if [ "$3" = "--python" ]; then
    PYTHON=$4
fi

if [ "$3" = "--pythonpath" ]; then
    PYTHONPATH=$4
fi

for file in test_dir_hfst.py test_dir_hfst_exceptions.py test_dir_hfst_rules.py \
    test_tokenizer.py test_exceptions.py test_xre.py \
    test_read_att_transducer.py test_prolog.py \
    test_att_reader.py test_prolog_reader.py \
    test_hfst.py test_examples.py test_pmatch.py test_xerox_rules.py;
do
    if ! [ "$PYTHONPATH" = "" ]; then
        echo 'import sys' > tmp
        echo 'sys.path.insert(0, "'$PYTHONPATH'")' >> tmp
        cat $file >> tmp
    else
        cat $file > tmp
    fi
    if ( $PYTHON tmp 2> /dev/null > /dev/null ); then
        echo $file" passed"
    else
        echo $file" failed"
        exit 1
    fi
done

if ! [ "$PYTHONPATH" = "" ]; then
    echo 'import sys' > tmp1
    echo 'sys.path.insert(0, "'$PYTHONPATH'")' >> tmp1
    cat test_streams_1.py >> tmp1
    echo 'import sys' > tmp2
    echo 'sys.path.insert(0, "'$PYTHONPATH'")' >> tmp2
    cat test_streams_2.py >> tmp2
    echo 'import sys' > tmp3
    echo 'sys.path.insert(0, "'$PYTHONPATH'")' >> tmp3
    cat test_streams_3.py >> tmp3
else
    cat test_streams_1.py > tmp1
    cat test_streams_2.py > tmp2
    cat test_streams_3.py > tmp3
fi

for format in sfst openfst foma;
do
    if ( $PYTHON tmp1 $format | $PYTHON tmp2 $format | $PYTHON tmp3 $format ); then
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
rm tmp
rm tmp1
rm tmp2
rm tmp3
