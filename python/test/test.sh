#for file in test_hfst.py examples.py test.py; do
#    if python3 $file > /dev/null 2> /dev/null; then
#        echo $file" passed" 
#    else
#        echo $file" failed" 
#    fi
#done

#for n in 2 3 5 7 9; do
#    if python3 test$n.py > /dev/null 2> /dev/null; then
#        echo "test"$n".py passed" 
#    else
#        echo "test"$n".py failed" 
#    fi
#done

#echo "skipping test4.py"
#echo "skipping test8.py"

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

for file in test_pmatch.py test_prolog.py test_exceptions.py test_dir_hfst.py \
    test_dir_hfst_exceptions.py test_dir_hfst_rules.py test_tokenizer.py \
    test_read_att_transducer.py test_xre.py test_hfst.py examples.py ;
do
    if ! [ "$PYTHONPATH" = "" ]; then
        echo 'import sys' > tmp
        echo 'sys.path.insert(0, "'$PYTHONPATH'")' >> tmp
        cat $file >> tmp
    else
        cat $file > tmp
    fi
    if (python3 tmp); then
        echo $file" passed"
    else
        echo $file" failed"
    fi
done
