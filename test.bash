#!/bin/bash

set -ex

if [[ -z "$PYTHON" ]]
then
    PYTHON=python
fi

trap "echo -e '\x1b[01;31mFailed\x1b[0m'" ERR

# Unreadable files should be handled gracefully.
touch test/unreadable.json
touch test/unreadable.yaml
trap 'rm -f test/unreadable.json test/unreadable.yaml' EXIT
chmod ugo-r test/unreadable.json
chmod ugo-r test/unreadable.yaml

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/good.cfg
"$PYTHON" ./syntax_checkers/cfg/cfg.py test/good_with_subsections.cfg
"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/good.c
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/good.cpp
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_c_config gcc -x c test/foo/bar.h
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ -x c++ test/foo/bar.h
"$PYTHON" ./syntax_checkers/gitcommit/proselint_wrapper.py test/good.gitcommit

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.cfg 2>&1 \
    | grep 'test/bad.cfg:2' > /dev/null
"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad_with_subsections.cfg 2>&1 \
    | grep 'test/bad_with_subsections.cfg:2' > /dev/null

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.ini 2>&1 \
    | grep 'test/bad.ini:2' > /dev/null

"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/bad.c 2>&1 \
    | grep 'test/bad.c:3' > /dev/null

"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/bad.cpp 2>&1 \
    | grep 'test/bad.cpp:3' > /dev/null

"$PYTHON" ./syntax_checkers/gitcommit/proselint_wrapper.py test/bad.gitcommit 2>& 1 \
    | grep 'test/bad.gitcommit:3' > /dev/null

if "$PYTHON" -c 'import yaml' >& /dev/null
then
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/good.yaml
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/bad.yaml 2>&1 \
        | grep 'test/bad.yaml:2'
    "$PYTHON" ./syntax_checkers/yaml/check_yaml.py test/unreadable.yaml 2>&1 \
        | grep 'unreadable.yaml'
fi

if "$PYTHON" -c 'import json' >& /dev/null
then
    "$PYTHON" ./syntax_checkers/javascript/json_tool.py test/good.json
    "$PYTHON" ./syntax_checkers/javascript/json_tool.py test/bad.json 2>&1 \
        | grep 'test/bad.json:2'
    "$PYTHON" ./syntax_checkers/javascript/json_tool.py test/unreadable.json 2>&1 \
        | grep 'unreadable.json'
fi

"$PYTHON" ./syntax_checkers/cpp/check.py unreadable echo echo

# Do not run this under Python 2.4.
python -m doctest syntax_checkers/*/*.py

echo -e '\x1b[01;32mOkay\x1b[0m'
