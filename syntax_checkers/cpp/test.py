#!/usr/bin/env python

"""Utility to easily use `check.py` from the command line instead of Vim."""

import os
import sys

import check


def is_file(path):
    """Return True if path is a regular file.

    This is case sensitive.

    """
    (directory, base_filename) = os.path.split(path)
    return base_filename in os.listdir(directory)


def get_command(source_code_filename):
    if is_cpp(source_code_filename):
        return [os.getenv('CXX', 'g++'), '-x', 'c++']
    else:
        return [os.getenv('CC', 'gcc'), '-x', 'c']


def get_configuration_base_name(source_code_filename):
    if is_cpp(source_code_filename):
        return '.syntastic_cpp_config'
    else:
        return '.syntastic_c_config'


def is_cpp(filename):
    (root, extension) = os.path.splitext(filename)
    if extension == '.c':
        return False
    elif extension == '.h':
        # This could be C or C++. Guess based on its sibling file.
        # Use a case sensitive variant of `os.path.isfile()` since `.C` would
        # be C++.
        if is_file(root + '.c'):
            return False
        else:
            return True
    elif extension in ['.hh', '.hpp', '.h++', '.hxx']:
        return True
    else:
        return True


def main():
    exit_status = 0

    for filename in sys.argv[1:]:
        filename = os.path.abspath(filename)

        configuration_filename = check.find_configuration(
            start_path=filename,
            configuration_filename=get_configuration_base_name(filename)
        ) or os.devnull

        for line in check.check(configuration_filename=configuration_filename,
                                command=get_command(filename),
                                filename=filename,
                                verbose_file=sys.stderr):
            sys.stderr.write(line)
            exit_status = 1

    return exit_status


if __name__ == '__main__':
    sys.exit(main())
