#!/usr/bin/env python

"""Check config file syntax."""

try:
    from configparser import ConfigParser
    import configparser
except ImportError:
    from ConfigParser import SafeConfigParser as ConfigParser
    import ConfigParser as configparser

import re
import sys


def main():
    if len(sys.argv) != 2:
        raise SystemExit('usage: %s filename' % (sys.argv[0],))
    filename = sys.argv[1]

    parser = ConfigParser()

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

        sys.stderr.write('%s:%s: %s\n' %
                         (filename, line_number, error.message))


if __name__ == '__main__':
    sys.exit(main())
