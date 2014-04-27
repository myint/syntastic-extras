#!/usr/bin/env python

"""Check YAML syntax."""

import sys


def main():
    try:
        import yaml
    except ImportError:
        # Don't do anything if yaml module is not available.
        return 0

    if len(sys.argv) != 2:
        raise SystemExit('usage: %s filename' % (sys.argv[0],))
    filename = sys.argv[1]

    # Use ugly syntax to support very old versions of Python.
    try:
        try:
            input_file = open(filename, 'rb')
            yaml.load(input_file)
        finally:
            input_file.close()
    except yaml.error.YAMLError:
        error = sys.exc_info()[1]
        mark = error.problem_mark

        sys.stderr.write('%s:%s:%s: %s\n' %
                         (filename,
                          mark.line + 1,
                          mark.column + 1,
                          error.problem))


if __name__ == '__main__':
    sys.exit(main())
