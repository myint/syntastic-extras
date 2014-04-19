#!/usr/bin/env python

try:
    from configparser import ConfigParser
    import configparser
except ImportError:
    from ConfigParser import SafeConfigParser as ConfigParser
    import ConfigParser as configparser

import re
import sys


if len(sys.argv) != 2:
    raise SystemExit('usage: cfg_check.py filename')

parser = ConfigParser()

# Use ugly syntax to support very old versions of Python.
try:
    parser.read(sys.argv[1])
except configparser.Error:
    error = sys.exc_info()[1]

    line_number = getattr(error, 'lineno', 0)
    if not line_number:
        found = re.search(r'\[line  ([0-9]+)\]', error.message)
        if found:
            line_number = int(found.group(1))

    sys.stderr.write('%s:%s: %s\n' %
                     (error.filename, line_number, error.message))
