#!/usr/bin/env python
"""
Reformat a data file to change the format of the fields.
This script arises from the fact that g95 is stricter than pgf90
about free-format input.  For instance, data read into integer
variable must be represented as integers (not reals) in the
data file.

The Sand Heads wind data file SH20012345.dat, and the cloud
fraction data file xxx are examples of files that needed reformating.

Usage: fixDataFile.py "%i %i %i %e %e %e" <oldfile >newfile

The first argument is the (quoted) format specification for the
reformatted file.  The spec uses Python string formatting, which is
similar to the formatting used in the C printf() function.
"""

# $Id$

from optparse import OptionParser   # stdlib command line option parser
import sys                          # stdlib system bindings

# Build the command line option parser and parse the command line
parser = OptionParser()
(options, args) = parser.parse_args()

# Make sure that we have a format string
if len(args) != 1:
    sys.stderr.write("Missing format string argument...\n")
else:
    # Convert the format string argument into a list of field formats
    fmt = args[0].split(' ')

    # Read file to be converted line by line from stdin
    while True:
        try:
            line = raw_input()
        except EOFError:
            break
        else:
            # Split the line of data at spaces, ignoring peices that end up
            # empty, and strip the whitespace off the pieces we keep
            line = [num.strip() for num in line.split(' ') if num]

            # Make sure that the format string argument and the data line
            # have the same number of fields
            if len(line) != len(fmt):
                sys.stderr.write("Number of fields not matched...\n")
                break
            else:
                # Write the reformatted data to stdout
                for f, field in zip(fmt, line):
                    if f[-1] in ('i', 'd', 'u'):
                        print f % int(float(field)),
                    elif f[-1] in ('e', 'E', 'f', 'g', 'G'):
                        print f % float(field),
                print ''
