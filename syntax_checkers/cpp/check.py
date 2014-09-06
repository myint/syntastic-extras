#!/usr/bin/env python

"""Check C++ file syntax."""

import locale
import os
import shlex
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
            relative_path = line[len(INCLUDE_OPTION):].lstrip()
            options.append(os.path.join(os.path.dirname(configuration_path),
                                        relative_path))
        else:
            for token in shlex.split(line):
                options.append(token)

    return options


def main():
    if len(sys.argv) != 3:
        raise SystemExit('usage: %s compiler filename' % (sys.argv[0],))
    compiler = sys.argv[1]
    filename = sys.argv[2]

    options = read_configuration(filename)

    if options is None:
        return 0

    process = subprocess.Popen([compiler, '-fsyntax-only'] +
                               options + [filename],
                               stderr=subprocess.PIPE)

    errors = process.communicate()[1]
    if sys.version_info[0] > 2:
        errors = errors.decode(locale.getpreferredencoding())

    exit_status = 0

    for line in errors.splitlines(True):
        if filename in line:
            sys.stderr.write(line)
            exit_status = 1

    return exit_status


if __name__ == '__main__':
    sys.exit(main())
