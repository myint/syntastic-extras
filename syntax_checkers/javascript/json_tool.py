#!/usr/bin/env python

"""Check JSON syntax."""

import re
import sys


def main():
    try:
        import json
    except ImportError:
        # Don't do anything if json module is not available.
        return 0

    if len(sys.argv) != 2:
        raise SystemExit('usage: %s filename' % (sys.argv[0],))
    filename = sys.argv[1]

    # We need this since Vim considers "*.json" files to be "javascript".
    # This checker only works with JSON.
    if not filename.endswith('.json'):
        return 0

    try:
        input_file = open(filename, 'r')
        try:
            json.load(input_file)
        finally:
            input_file.close()
    except ValueError:
        message = str(sys.exc_info()[1])
        line_number = 0
        column = 0

        found = re.search(r': line\s+([0-9]+) column\s+([0-9]+)[^:]*$',
                          message)
        if found:
            line_number = int(found.group(1))
            column = int(found.group(2))

        sys.stderr.write('%s:%s:%s: %s\n' %
                         (filename,
                          line_number,
                          column,
                          message))

        return 1
    except IOError:
        sys.stderr.write('%s\n' % (sys.exc_info()[1],))
        return 1


if __name__ == '__main__':
    sys.exit(main())
