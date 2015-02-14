#!/bin/bash -ex

if [[ -z "$PYTHON" ]]
then
    PYTHON=python
fi

trap "echo -e '\x1b[01;31mFailed\x1b[0m'" ERR

# Unreadable files should be handled gracefully.
touch test/unreadable
trap 'rm test/unreadable' EXIT
chmod ugo-r test/unreadable

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/good.cfg
"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/good.c
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/good.cpp
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_c_config gcc -x c test/foo/bar.h
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ -x c++ test/foo/bar.h

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.cfg 2>&1 \
    | grep 'test/bad.cfg:2' > /dev/null

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.ini 2>&1 \
    | grep 'test/bad.ini:2' > /dev/null

"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/bad.c 2>&1 \
    | grep 'test/bad.c:3' > /dev/null

"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/bad.cpp 2>&1 \
    | grep 'test/bad.cpp:3' > /dev/null

if "$PYTHON" -c 'import yaml' >& /dev/null
then
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/good.yaml
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/bad.yaml 2>&1 \
        | grep 'test/bad.yaml:2'
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/unreadable 2>&1 \
        | grep 'unreadable'
fi

"$PYTHON" ./syntax_checkers/cpp/check.py unreadable echo echo

# Do not run this under Python 2.4.
python -m doctest syntax_checkers/*/*.py

echo -e '\x1b[01;32mOkay\x1b[0m'
