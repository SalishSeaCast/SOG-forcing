#!/usr/bin/env python
"""Process raw Environment Canada meteorology data files from YVR
station to produce cloud fraction, humidity, and temperature forcing
data files for the SOG bio-physical model of the Strait of Georgia.
"""

# $Id$

# Standard library modules
from datetime import datetime, time, timedelta
from math import exp
from optparse import OptionParser
import re
from sys import stdout, stderr
from warnings import warn


def main():
    """Parse the command line and initiate processing according to the
    input file argument and options specified by the user.

    """
    # Build command line option parser, and use it
    parser = build_parser()
    (options, args) = parser.parse_args()
    # Process the arguments and options
    # Too few or too many arguments: display help
    if len(args) != 1:
        parser.error("exactly 1 argument required; use -h option for help")
    # Self-test ignores argument and options
    if options.selftest:
        stderr.write("Running self-test; input file and options ignored.\n")
    # Process the data
    process_data(inputfile=args[0], cf_file=options.cf_file,
                 hum_file=options.hum_file, atemp_file=options.atemp_file,
                 overwrite=options.overwrite, selftest=options.selftest)


def build_parser():
    """Build the command line parser."""
    # Instantiate an option parser object
    parser = OptionParser()
    # Set usage and description texts
    parser.usage = "%prog [options] input_file"
    parser.description = \
"""Process raw Environment Canada meteorology data files from YVR
station to produce cloud fraction, humidity, and temperature forcing
data files for the SOG bio-physical model of the Strait of Georgia."""
    # Set options
    parser.add_option("--cf", dest="cf_file",
                      help="name of cloud fraction output file; "
                      + "defaults to cfYYYYMMDD.dat, "
                      + "where YYYYMMDD is the start date"
                      + "of the contents of the input data file; "
                      + "if the file exists, data will be appended, "
                      + "unless the -o option is present")
    parser.add_option("--hum", dest="hum_file",
                      help="name of humidity output file; "
                      + "defaults to humYYYYMMDD.dat, "
                      + "where YYYYMMDD is the start date "
                      + "of the contents of the input data file; "
                      + "if the file exists, data will be appended, "
                      + "unless the -o option is present")
    parser.add_option("--atemp", dest="atemp_file",
                      help="name of air temperature output file; "
                      + "defaults to atempYYYYMMDD.dat, "
                      + "where YYYYMMDD is the start date "
                      + "of the contents of the input data file; "
                      + "if the file exists, data will be appended, "
                      + "unless the -o option is present")
    parser.add_option("-o", "--overwrite",
                      action="store_true", dest="overwrite",
                      help="overwrite output files if they already exist; "
                      + "default: %default")
    parser.add_option("-t", "--selftest",
                      action="store_true", dest="selftest",
                      help="run built-in self-test")
    parser.set_defaults(overwrite=False, selftest=False)
    return parser


def process_data(inputfile, cf_file, hum_file, atemp_file,
                 overwrite, selftest):
    """docstring"""
    # Initializations:
    # Lists for cf, humidity, and temperature to hold 24 hours worth of
    # data that goes into 1 output record
    cf, hum, atemp = [], [], []
    # Line counter for flagging problems in the input
    lines_read = 0
    # Flag to ensure that the first day's data output starts at midnight PST
    firstday = True
    # Nominal  datetime of the last line read for catching missing data lines
    last_datetime = None
    # Regular expression of all digits for parsing cloud string
    clouds_re = re.compile('[A-Z]')
    # Format string for output files
    fmt = "1108447 %i %i %i %i "
    fmt += "%.1f %.1f %.1f %.1f %.1f %.1f %.1f %.1f "
    fmt += "%.1f %.1f %.1f %.1f %.1f %.1f %.1f %.1f "
    fmt += "%.1f %.1f %.1f %.1f %.1f %.1f %.1f %.1f\n"
    # File handle for error messages
    err = stderr

    # Open the input data file, if it exists
    try:
        met_file = open(inputfile, 'r')
    except IOError:
        raise SystemExit("Error: input file not found")
    # Read the input data a line at a time
    for line in met_file:
        lines_read += 1
        # Skip empty lines
        if line == '\n':
            continue
        # Parse the line it into space-delimited fields
        line = line.split(' ')
        # Process the line only if the record-type field value is SA
        if line[3] == 'SA':
            # Confirm that the station field value is YVR, otherwise
            # raise a warning
            if line[2] != 'YVR':
                msg = "Warning: at line %i: " % lines_read
                msg += "station != YVR\n"
                err.write(msg)
            # Parse record and nominal date/times, and adjust them to PST
            (rec_datetime, nom_datetime) = parse_times(line)
            # Skip lines until we find midnight PST to start output with
            if firstday:
                if rec_datetime.hour != 0:
                    cf, hum, atemp = [], [], []
                else:
                    # Open output files
                    # Date to use in output file name if it's not specified
                    outfile_date = rec_datetime.strftime('%Y%m%d')
                    outfiles = [(cf_file, 'cf'), (hum_file, 'hum'),
                                (atemp_file, 'atemp')]
                    handle = []
                    for (fname, prefix) in outfiles:
                        if fname is None:
                            # Use default file name
                            fname = ''.join((prefix, outfile_date, '.dat'))
                        if overwrite:
                            handle.append(open(fname, 'w'))
                        else:
                            # Append creates file if it doesn't exist
                            handle.append(open(fname, 'a'))
                    (cf_out, hum_out, atemp_out) = tuple(handle)
                    firstday = False
            # Check for difference of > 30 min between record date/time and
            # nominal time, and raise a warning if found
            # (Note that subtraction is not defined for datetime.time objects)
            if abs(rec_datetime - nom_datetime) > timedelta(minutes=30):
                msg = "Warning: at line %i: " % lines_read
                msg += "rec & nom time differ > 30 min: " 
                msg += " rec = %s" % rec_datetime.isoformat(' ')
                msg += "  nom = %s\n" % nom_datetime.isoformat(' ')
                err.write(msg)
            # Check for missing data (> 1 hr between records)
            if (last_datetime is not None and
                nom_datetime - last_datetime > timedelta(hours=1)):
                    # Raise a warning
                    msg = "Warning: at line %i: " % lines_read
                    msg += "missing data: "
                    msg += "prev hr = %i PST" % last_datetime.hour
                    msg += "  current hr = %i PST\n" % nom_datetime.hour
                    err.write(msg)
                    # Fill missing data with 999 to flag it for
                    # interpolation later
                    if nom_datetime.hour != 0:
                        missing_hrs = range(last_datetime.hour + 1,
                                            nom_datetime.hour)
                    else:
                        missing_hrs = range(last_datetime.hour + 1, 24)
                    for hr in missing_hrs:
                        cf.append(999)
                        hum.append(999)
                        atemp.append(999)
            else:
                # Find the field that contains the /-delimited
                # numerical data
                field = [f for f in line[6:] if f.find('/') != -1]
                if field == []:
                    msg = "Warning: at line %i: " % lines_read
                    msg += "unable to find /-delimited met data\n"
                    err.write(msg)
                else:
                    num_data = field[0].split('/')
                # Get cloud fraction value
                cf.append(get_cloud_fraction(line, rec_datetime, num_data,
                                             clouds_re, lines_read, err))
                # Get air temperature value
                atemp.append(get_air_temp(num_data))
                # Calculate relative humidity value
                hum.append(calc_humidity(num_data))
            # Store nominal datetime to check for missing data
            last_datetime = nom_datetime

        # Write data to files, if we're at the end of the day
        if len(cf) == 24:
            prefix = (rec_datetime.year - 2000, rec_datetime.month,
                      rec_datetime.day)
            out = [(cf_out, 82, cf), (hum_out, 80, hum),
                   (atemp_out, 78, atemp)]
            for (f, para, array) in out:
                f.write(fmt % (prefix + (para, ) + tuple(array)))
            # Reset data list, ready for next day
            cf, hum, atemp = [], [], []

    # End of input data reached
    print '\n', lines_read, "lines of data processed"


def parse_times(fields):
    """docstring"""
    # Parse the record date and time fields into a datetime object
    year, month, day = fields[0].split('/')
    year, month, day = int(year), int(month), int(day)
    hour, minute, second = fields[1].split(':')
    hour, minute, second = int(hour), int(minute), int(second)
    rec_datetime = datetime(year, month, day, hour, minute, second)
    # Parse the nominal time into a time object
    hour = int(fields[4][:2])
    minute = int(fields[4][2:])
    nom_datetime = rec_datetime.replace(hour=hour, minute=minute, second=0)
    # Adjust the record and nominal date/times from UTC to PST
    rec_datetime -= timedelta(hours=8)
    nom_datetime -= timedelta(hours=8)
    return (rec_datetime, nom_datetime)


def get_cloud_fraction(fields, rec_datetime, num_data, clouds_re,
                       lines_read, err):
    """Get cloud fraction value."""
    if fields[5] == 'CLR':
        # Clear sky = cloud fraction zero
        cf = 0
    else:
        if rec_datetime < datetime(2003, 8, 21):
            # Older cloud strings may be inaccurate, so get cloud
            # fraction from summary field; character before last ?
            cloud_data = [f for f in fields[6:] if f.find('?') != -1]
            if cloud_data == []:
                cf = 999
                msg = "Warning: at line %i: " % lines_read
                msg += "unable to find ?-delimited cloud fraction\n"
                err.write(msg)
            else:
                i = cloud_data[0].rfind('?')
                v = cloud_data[0][i-1:i]
                if v == 'X':
                    # Overcast sky = cloud fraction 10
                    cf = 10
                else:
                    cf = int(v)
        else:
            # Parse cloud string from /-delimited field into cloud
            # fractions
            cloud_data = clouds_re.split(num_data[-1])
            # Sum the fractions
            cf = (sum([int(x) for x in cloud_data if x != '']))
        if cf > 10 and cf < 999:
            # Cloud fraction must be in range 0 to 10
            cf = 10
            msg = "Warning: at line %i: " % lines_read
            msg += "cloud fraction > 10, set to 10\n"
            err.write(msg)
    return cf


def get_air_temp(num_data):
    """Get air temperature value."""
    # Multiplied by 10 as SOG expects
    return 10. * float(num_data[1])


def calc_humidity(num_data):
    """Calculate relative humidity value from air temperature and dew
    point temperature using Claudius-Clapeyron equation.

    """
    # Temperatures converted to Kelvin:
    T = float(num_data[1]) + 273.15
    Td = float(num_data[2]) + 273.15
    # Claudius-Clapeyron constants:
    L = 2.453e6
    Rv = 461.5
    # Claudius-Clapeyron equation multiplied by 100
    hum = exp((1. / T - 1. / Td) * L / Rv)
    # Return humidity as a percent value as SOG expects it
    return hum * 100.



if __name__ == '__main__':
    main()

# end of file
