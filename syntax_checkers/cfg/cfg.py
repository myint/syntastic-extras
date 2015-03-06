#!/usr/bin/env python

"""Check config file syntax."""

try:
    import configparser
except ImportError:
    import ConfigParser as configparser

import os
import re
import sys

try:
    import configobj
except ImportError:
    configobj = None


def check_configobj(filename):
    """Check file using configobj.

    Return list of (line_number, message) tuples.

    """
    errors = []

    class Parser(configobj.ConfigObj):

        def _handle_error(self, text, ErrorClass, infile, cur_index):
            # Remove irrelevant text in old versions of configobj (<=4).
            text = re.sub(r' *at line "?%s"?\. *$', '', text)

            errors.append((cur_index + 1, text))

    Parser(filename,
           list_values=False)  # Avoid complaining about the values.

    return errors


def check_configparser(filename):
    """Check file using configparser.

    Return list of (line_number, message) tuples.

    """
    parser = configparser.RawConfigParser()

    errors = []

    # Use ugly syntax to support very old versions of Python.
    try:
        parser.read(filename)
    except configparser.MissingSectionHeaderError:
        # Ignore non-standard cfg files.
        pass
    except configparser.Error:
        error = sys.exc_info()[1]

        line_number = getattr(error, 'lineno', 0)
        if not line_number:
            found = re.search(r'\[line\s+([0-9]+)\]', error.message)
            if found:
                line_number = int(found.group(1))

        errors.append((line_number, error.message))

    return errors


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: %s filename' % (sys.argv[0],))
    filename = sys.argv[1]

    # Default to configobj first since it supports subsections and has better
    # error messages.
    if configobj and not os.getenv('SYNTASTIC_EXTRAS_USE_CONFIG_PARSER'):
        errors = check_configobj(filename)
    else:
        errors = check_configparser(filename)

    for (line_number, message) in errors:
        sys.stderr.write('%s:%s: %s\n' %
                         (filename, line_number, message))
        return 1


if __name__ == '__main__':
    sys.exit(main())
