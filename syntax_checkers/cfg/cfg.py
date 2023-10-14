#!/usr/bin/env python3

"""Check config file syntax."""

try:
    import configparser
except ImportError:
    import ConfigParser as configparser

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

    if not configobj:
        return errors

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

        message = re.sub(r"^While reading from '.*' \[line *[0-9]+\]: *",
                         '',
                         error.message.splitlines()[0]).capitalize()

        errors.append((line_number, message))

    return errors


def might_be_configobj_format(filename):
    input_file = open(filename)
    try:
        for line in input_file.readlines():
            # Check if there is a subsection.
            if re.match(r'^\s*\[\[.*\]\]\s*$', line):
                return True
    finally:
        input_file.close()

    return False


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: %s filename' % (sys.argv[0],))
    filename = sys.argv[1]

    try:
        # Use configobj only if there seems to be subsections. In such cases,
        # configobj is needed. Otherwise don't use it since there is syntax in
        # configparser that configobj does not understand. An example of this
        # is multiline values. configparser supports this, but configobj
        # requires triple quotes.
        if might_be_configobj_format(filename):
            errors = check_configobj(filename)
        else:
            errors = check_configparser(filename)

        for (line_number, message) in errors:
            sys.stderr.write('%s:%s: %s\n' %
                             (filename, line_number, message))
            return 1
    except IOError:
        # Ignore unreadable files.
        pass


if __name__ == '__main__':
    sys.exit(main())
