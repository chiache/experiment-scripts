#!/usr/bin/python

import sys

if len(sys.argv) < 2:
    print "USAGE:", sys.argv[0], "FILE [DEF|^DEF] ..."
    exit(0)

filename = sys.argv[1]
file = open(filename, 'r')

comment_level = -1
nested = 0

defined = []
undefined = []

for arg in sys.argv[2:]:
    if arg[0] == '^':
        undefined.append(arg[1:])
    else:
        defined.append(arg)

for line in file:
    scan = line.strip()
    print_this_line = True

    if scan.startswith("#"):
        scan = scan[1:].strip()

        if scan.startswith("if 0"):
            if comment_level == -1:
                comment_level = nested
            nested = nested + 1

        if scan.startswith("ifdef "):
            for sym in undefined:
                if scan[6:] == sym and comment_level == -1:
                    comment_level = nested
            nested = nested + 1

        if scan.startswith("ifndef "):
            for sym in defined:
                if scan[6:] == sym and comment_level == -1:
                    comment_level = nested
            nested = nested + 1

        if scan.startswith("endif"):
            nested = nested - 1
            if comment_level == nested:
                comment_level = -1
            print_this_line = False

    if comment_level == -1 and print_this_line:
        sys.stdout.write(line)
