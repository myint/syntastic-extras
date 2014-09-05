#!/usr/bin/env python

"""Check C++ file syntax."""

import os
import subprocess
import sys


def find_configuration(start_path):
    """Return path to configuration.

    Return None if there is no configuration.

    """
    while start_path:
        start_path = os.path.dirname(start_path)

        configuration_path = os.path.join(start_path, '.syntastic_cpp_config')
        if os.path.exists(configuration_path):
            return configuration_path

        if start_path == os.sep:
            break

    return None


def read_configuration(start_path):
    """Return compiler options from configuration.

    Return None if there is no configuration.

    """
    configuration_path = find_configuration(os.path.abspath(start_path))
    if configuration_path:
        input_file = None
        try:
            input_file = open(configuration_path)
            return input_file.read().splitlines()
        finally:
            if input_file:
                input_file.close()
    else:
        return None


def main():
    if len(sys.argv) != 3:
        raise SystemExit('usage: %s compiler filename' % (sys.argv[0],))
    compiler = sys.argv[1]
    filename = sys.argv[2]

    options = read_configuration(filename)

    if options is None:
        return 0

    return subprocess.call([compiler, '-fsyntax-only'] + options + [filename])


if __name__ == '__main__':
    sys.exit(main())
