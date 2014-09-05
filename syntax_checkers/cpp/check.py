#!/usr/bin/env python

"""Check C++ file syntax."""

import os
import subprocess
import sys

INCLUDE_OPTION = '-I'


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


def read_lines(filename):
    """Return split lines from file without line endings."""
    input_file = None
    try:
        input_file = open(filename)
        lines = input_file.read().splitlines()
    finally:
        if input_file:
            input_file.close()
    return lines


def read_configuration(start_path):
    """Return compiler options from configuration.

    Return None if there is no configuration.

    """
    configuration_path = find_configuration(os.path.abspath(start_path))
    if configuration_path:
        raw_lines = read_lines(configuration_path)
    else:
        return None

    options = []
    for line in raw_lines:
        if line.startswith(INCLUDE_OPTION):
            options.append('-isystem')
            options.append(line[len(INCLUDE_OPTION):].lstrip())
        else:
            options.append(line)

    return options


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
