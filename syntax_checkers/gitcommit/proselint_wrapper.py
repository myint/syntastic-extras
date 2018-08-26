#!/usr/bin/env python

"""Remove comments before passing output to proselint."""

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
                    # Ignore everything below the comments like the diff that
                    # shows up in verbose commit mode.
                    break
                else:
                    input_lines.append(line)
        finally:
            input_file.close()
    except IOError:
        # Ignore unreadable file.
        sys.stderr.write('%s\n' % (sys.exc_info()[1],))
        return 1

    try:
        process = subprocess.Popen(['proselint', '-'],
                                   stdin=subprocess.PIPE,
                                   stdout=subprocess.PIPE)
    except OSError:
        # Ignore if proselint is not installed.
        return 0

    encoding = locale.getpreferredencoding()

    output = process.communicate(''.join(input_lines).encode(encoding))[0]

    if sys.version_info[0] > 2:
        output = output.decode(encoding)

    for line in output.splitlines(True):
        # proselint 0.10 changed the output message from `-:` to `<stdin>:`.
        filtered_line = re.sub('^(-|<stdin>):', filename + ':', line)
        sys.stdout.write(filtered_line)

    return process.returncode


if __name__ == '__main__':
    sys.exit(main())
