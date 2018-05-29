#!/usr/bin/env python

"""Check C/C++ file syntax."""

import locale
import os
import shlex
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


def find_compile_commands_json(source_filename):
    """Return path to `compile_commands.json` generated by CMake."""
    start_path = os.path.abspath(source_filename)
    last_path = start_path

    while start_path:
        start_path = os.path.dirname(start_path)

        configuration_path = os.path.join(start_path,
                                          'build',
                                          'compile_commands.json')
        if os.path.exists(configuration_path):
            return configuration_path

        if start_path == last_path:
            break

        last_path = start_path

    return None


def get_compile_options(command, filename):
    """Return compile options for syntax checking."""
    options = []

    index = 1
    while True:
        try:
            item = command[index]
        except IndexError:
            break

        index += 1

        try:
            if os.path.samefile(item, filename):
                continue
        except OSError:
            pass

        if item == '-o':
            index += 1
            continue

        options.append(item)

    return options


def read_compile_commands_json(source_filename):
    """Return path to `compile_commands.json` generated by CMake."""
    json_filename = find_compile_commands_json(source_filename)
    if json_filename is None:
        return None

    try:
        import json
    except ImportError:
        # Old Python.
        return None

    try:
        input_file = None
        try:
            input_file = open(json_filename)
            compile_commands = json.load(input_file)
        finally:
            if input_file:
                input_file.close()
    except OSError:
        return None

    for entry in compile_commands:
        try:
            if os.path.samefile(entry['file'], source_filename):
                command = entry['command'].split()
                return get_compile_options(command, source_filename)
        except OSError:
            pass

    return None



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


def check(configuration_filename, command, filename, verbose_file=None):
    """Return list of error messages."""
    options = read_configuration(filename,
                                 configuration_filename=configuration_filename)

    if options is None:
        # Otherwise look for a configuration generated by CMake.
        options = read_compile_commands_json(filename)
        if options is None:
            return []

    if is_header_file(filename):
        # Avoid generating precompiled headers.
        options += ['-c', os.devnull]


    full_command = command + ['-fsyntax-only'] + options + [filename]

    if verbose_file:
        verbose_file.write(' '.join(full_command) + '\n')

    process = subprocess.Popen(command + ['-fsyntax-only'] +
                               options + [filename],
                               stderr=subprocess.PIPE)

    errors = process.communicate()[1]
    if sys.version_info[0] > 2:
        errors = errors.decode(locale.getpreferredencoding())

    return errors.splitlines(True)


def main():
    if len(sys.argv) < 4:
        raise SystemExit('usage: %s configuration_filename command filename' %
                         (sys.argv[0],))

    exit_status = 0

    for line in check(configuration_filename=sys.argv[1],
                      command=sys.argv[2:-1],
                      filename=sys.argv[-1]):
        sys.stderr.write(line)
        exit_status = 1

    return exit_status


if __name__ == '__main__':
    sys.exit(main())
