#!/usr/bin/env python

"""Remove comments before passing output to proselint."""

# Use ugly syntax to support very old versions of Python.

import locale
import re
import subprocess
import sys


def main():
    if len(sys.argv) != 2:
        sys.stderr.write('Usage: ' + sys.argv[0] + ' filename\n')
        return 2

    filename = sys.argv[1]

    input_lines = []
    try:
        input_file = open(filename)
        try:
            for line in input_file.readlines():
                if line.startswith('#'):
                    input_lines.append('\n')
                else:
                    input_lines.append(line)
        finally:
            input_file.close()
    except IOError:
        # Ignore unreadable file.
        pass

    process = subprocess.Popen(['proselint', '-'],
                               stdin=subprocess.PIPE,
                               stdout=subprocess.PIPE)

    encoding = locale.getpreferredencoding()

    output = process.communicate(''.join(input_lines).encode(encoding))[0]

    if sys.version_info[0] > 2:
        output = output.decode(encoding)

    for line in output.splitlines(True):
        filtered_line = re.sub('^-:', filename + ':', line)
        sys.stdout.write(filtered_line)


if __name__ == '__main__':
    sys.exit(main())
