#!/bin/bash

set -ex

if [[ -z "$PYTHON" ]]
then
    PYTHON=python
fi

trap "echo -e '\x1b[01;31mFailed\x1b[0m'" ERR

readonly script_directory=$(dirname "$0")
cd "$script_directory"/..

# Unreadable files should be handled gracefully.
touch test/unreadable.json
touch test/unreadable.yaml
trap 'rm -f test/unreadable.json test/unreadable.yaml' EXIT
chmod ugo-r test/unreadable.json
chmod ugo-r test/unreadable.yaml

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/good.cfg
"$PYTHON" ./syntax_checkers/cfg/cfg.py test/good_with_subsections.cfg
"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/syntastic_config/good.c
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/syntastic_config/good.cpp
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_c_config gcc -x c test/syntastic_config/foo/bar.h
"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ -x c++ test/syntastic_config/foo/bar.h
"$PYTHON" ./syntax_checkers/gitcommit/proselint_wrapper.py test/good.gitcommit

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.cfg 2>&1 \
    | grep 'test/bad.cfg:2' > /dev/null
"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad_with_subsections.cfg 2>&1 \
    | grep 'test/bad_with_subsections.cfg:2' > /dev/null

"$PYTHON" ./syntax_checkers/cfg/cfg.py test/bad.ini 2>&1 \
    | grep 'test/bad.ini:2' > /dev/null

"$PYTHON" ./syntax_checkers/c/check.py .syntastic_c_config gcc test/syntastic_config/bad.c 2>&1 \
    | grep 'test/syntastic_config/bad.c:3' > /dev/null

"$PYTHON" ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/syntastic_config/bad.cpp 2>&1 \
    | grep 'test/syntastic_config/bad.cpp:3' > /dev/null

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
    "$PYTHON" ./syntax_checkers/json/json_tool.py test/good.json
    "$PYTHON" ./syntax_checkers/json/json_tool.py test/bad.json 2>&1 \
        | grep 'test/bad.json:2'
    "$PYTHON" ./syntax_checkers/json/json_tool.py test/unreadable.json 2>&1 \
        | grep 'unreadable.json'
fi

"$PYTHON" ./syntax_checkers/cpp/check.py unreadable echo echo

# Do not run this under Python 2.4.
python -m doctest syntax_checkers/*/*.py

"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good.cpp
"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/bad.cpp 2>&1 \
    | grep 'test/syntastic_config/bad.cpp:3' > /dev/null

"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good.c
"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/bad.c 2>&1 \
    | grep 'test/syntastic_config/bad.c:3' > /dev/null

"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good_header.h
"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good_header.cpp

"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/bad_header.h 2>&1 \
    | grep 'test/syntastic_config/bad_header.h:1' > /dev/null
"$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/bad_header.c 2>&1 \
    | grep 'test/syntastic_config/bad_header.c:1' > /dev/null

# Do not run this under Python 2.4 as it requires the `json` module.
python ./syntax_checkers/cpp/test.py test/compile_commands/good.cpp
python ./syntax_checkers/cpp/test.py test/compile_commands/bad.cpp 2>&1 \
    | grep 'test/compile_commands/bad.cpp:3' > /dev/null

python ./syntax_checkers/cpp/test.py test/bear_compile_commands/good.cpp
python ./syntax_checkers/cpp/test.py test/bear_compile_commands/bad.cpp 2>&1 \
    | grep 'test/bear_compile_commands/bad.cpp:3' > /dev/null

# With `CC` or `CXX` composed of multiple arguments.
CC='echo hello world' \
    "$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good.c \
    | grep 'hello world'
CXX='echo hello world' \
    "$PYTHON" ./syntax_checkers/cpp/test.py test/syntastic_config/good.cpp \
    | grep 'hello world'

echo -e '\x1b[01;32mOkay\x1b[0m'
