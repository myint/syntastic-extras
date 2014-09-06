#!/bin/bash -eux

trap "echo -e '\x1b[01;31mFailed\x1b[0m'" ERR

./syntax_checkers/cfg/cfg.py test/good.cfg
./syntax_checkers/c/check.py .syntastic_c_config gcc test/good.c
./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/good.cpp
./syntax_checkers/yaml/check_yaml.py test/good.yaml

./syntax_checkers/cfg/cfg.py test/bad.cfg 2>&1 \
    | grep 'test/bad.cfg:2' > /dev/null

./syntax_checkers/c/check.py .syntastic_c_config gcc test/bad.c 2>&1 \
    | grep 'test/bad.c:3' > /dev/null

./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/bad.cpp 2>&1 \
    | grep 'test/bad.cpp:3' > /dev/null

./syntax_checkers/yaml/check_yaml.py test/bad.yaml 2>&1 \
    | grep 'test/bad.yaml:2'

echo -e '\x1b[01;32mOkay\x1b[0m'
