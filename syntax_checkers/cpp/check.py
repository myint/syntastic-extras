#!/usr/bin/env python

"""Check C++ file syntax."""

import subprocess
import sys


def main():
    if len(sys.argv) != 3:
        raise SystemExit('usage: %s compiler filename' % (sys.argv[0],))
    compiler = sys.argv[1]
    filename = sys.argv[2]

    return subprocess.call([compiler, '-fsyntax-only', filename])


if __name__ == '__main__':
    sys.exit(main())
