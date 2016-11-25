#!/usr/bin/env python

"""Check C/C++ file syntax."""

import locale
import os
import shlex
import re
import subprocess
import sys

HEADER_EXTENSIONS = frozenset(['.h', '.hh', '.hpp', '.h++', '.hxx', '.cuh'])
INCLUDE_OPTION = '-I'


def find_configuration(start_path, configuration_filename):
    """Return path to configuration.

    Return None if there is no configuration.

    """
    while start_path:
        start_path = os.path.dirname(start_path)

        configuration_path = os.path.join(start_path, configuration_filename)
        if os.path.exists(configuration_path):
            return configuration_path

        if start_path == os.sep:
            break

    return None


def read_lines(filename):
    """Return split lines from file without line endings."""
    try:
        input_file = open(filename)
        try:
            lines = input_file.read().splitlines()
        finally:
            input_file.close()
    except IOError:
        return None

    return lines


def read_configuration(start_path, configuration_filename):
    """Return compiler options from configuration.

    Return None if there is no configuration.

    """
    configuration_path = find_configuration(
        os.path.abspath(start_path),
        configuration_filename=configuration_filename)

    raw_lines = None
    if configuration_path:
        raw_lines = read_lines(configuration_path)

    if raw_lines is None:
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


def is_header_file(filename):
    """Return True if "filename" is a header file.

    >>> is_header_file('foo.c')
    False

    >>> is_header_file('foo.h')
    True

    >>> is_header_file('foo.h++')
    True

    """
    extension = os.path.splitext(filename)[1]
    return extension.lower() in HEADER_EXTENSIONS


def main():
    if len(sys.argv) < 4:
        raise SystemExit('usage: %s configuration_filename command filename' %
                         (sys.argv[0],))
    configuration_filename = sys.argv[1]
    command = sys.argv[2:-1]
    filename = sys.argv[-1]

    options = read_configuration(filename,
                                 configuration_filename=configuration_filename)

    if options is None:
        return 0

    if is_header_file(filename):
        # Avoid generating precompiled headers.
        options += ['-c', os.devnull]

    process = subprocess.Popen(command + ['-fsyntax-only'] +
                               options + [filename],
                               stderr=subprocess.PIPE)

    errors = process.communicate()[1]
    if sys.version_info[0] > 2:
        errors = errors.decode(locale.getpreferredencoding())

    exit_status = 0
    regex = re.compile('[/a-zA-Z0-9-<>.]+:[0-9]+:[0-9]+:[a-zA-Z ]+:.*')

    for line in errors.splitlines(True):
        if re.search(regex, line):
            sys.stderr.write(line)
            exit_status = 1

    return exit_status


if __name__ == '__main__':
    sys.exit(main())
