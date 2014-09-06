#!/bin/bash -eux

./syntax_checkers/cfg/cfg.py test/good.cfg
./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/good.cpp
./syntax_checkers/yaml/check_yaml.py test/good.yaml

if ./syntax_checkers/cfg/cfg.py test/bad.cfg
then
    exit 1
fi

if ./syntax_checkers/cpp/check.py .syntastic_cpp_config g++ test/bad.cpp
then
    exit 1
fi

if ./syntax_checkers/yaml/check_yaml.py test/bad.yaml
then
    exit 1
fi

echo -e '\x1b[01;32mOkay\x1b[0m'
