#!/usr/bin/env python
"""
Retrieve and process METAR weather data from the Plymouth State
University archive site (vortex.plymouth.edu).

Usage:

  - ``METARcollector.py [options] station``

To run this script from a ``crontab`` that emails the error messages
and results, and also logs them to foo, and bar, respectively, do some
fancy footwork with file descriptor reassignment, pipes, and tee,
resulting in a command like this (only work in [ba|k]sh shells, not
[t]csh::

  (./METARcollector.py -i yvr | tee -a foo) 3>&1 1>&2 2>&3 | tee -a bar

Public Classes and Functions:

  - ``METARdata``: Retrieve and process METAR weather data from the
    Plymouth State University archive site (vortex.plymouth.edu).
  - ``get_met_data()``: Return a list of string of meteorological data for
    the specified station.

Exception Classes:

  - ``METARDataError``
  - ``UnknownParameterError``
  - ``UnknownStationError``
  - ``UnexpectedPageError``
  - ``InvalidDateError``
  - ``EndDateWithoutBeginError``


Unit Tests
----------

Create an instance and check the default property values:
  >>> metar = METARdata()
  >>> metar.site
  'http://vortex.plymouth.edu/cgi-bin/gen_statlog-u.cgi'
  >>> assert(date(year=metar.year, month=metar.month, day=metar.day)
  ...        == date.today() - timedelta(days=1))
  >>> print metar.stns['yvr'], metar.stns['sandheads']
  CYVR CWVF

  >>> print metar.get_met_data('yvr', year=2007, month=4, day=1)[0]
  2007 04 01 00 METAR CYVR 010000Z 28016G22KT 30SM FEW045 FEW230 09/00 A3005 RMK CU1CI1 SLP175
  <BLANKLINE>

Test exceptions:
  >>> metar.get_met_data('yvr', spam=42)
  Traceback (most recent call last):
      ...
  UnknownParameterError: ('spam', 42)
  
  >>> metar.get_met_data('yyz')
  Traceback (most recent call last):
      ...
  UnknownStationError: yyz

  >>> metar_data('yvr', '2007-13-12', None)
  Traceback (most recent call last):
      ...
  InvalidDateError: 2007-13-12

  >>> metar_data('yvr', '2007-04-04', '2007-04-01')
  Traceback (most recent call last):
      ...
  EndDateBeforeBeginError: ('2007-04-04', '2007-04-01')

"""

__author__ = 'Doug Latornell'
__version__ = '$Id$'
__docformat__ = 'restructuredtext'


from datetime import date, datetime, timedelta
import sys
import urllib


# Exceptions:
class METARDataError(Exception): pass
class WrongNumberOfArguments(METARDataError): pass
class UnknownParameterError(METARDataError): pass
class UnknownStationError(METARDataError): pass
class UnexpectedPageError(METARDataError): pass
class InvalidDateError(METARDataError): pass
class EndDateWithoutBeginError(METARDataError): pass
class EndDateBeforeBeginError(METARDataError): pass
    

class METARdata:

    """Retrieve and process METAR weather data from the Plymouth State
    University archive site (vortex.plymouth.edu).

    """

    def __init__(self):
        """
        Initialize a `METARdata` instance, and set its default
        property values.
        """
        self.site = ('http://vortex.plymouth.edu/cgi-bin/gen_statlog-u.cgi')
        """Root of URL to query for data."""
        yesterday = datetime.today() - timedelta(days=1)
        self.year = yesterday.year
        """Year to get data for."""
        self.month = yesterday.month
        """Month to get data for."""
        self.day = yesterday.day
        """Day to get data for."""
        self.stns = dict(yvr="CYVR",
                         sandheads="CWVF")
        """Mapping of common station names to official station IDs."""
        

    def get_met_data(self, stn, ignore_errors, retries, **kwargs):
        """Return a list of strings of METAR meteorological data for
        the specified station on sthe specified date.

        Each list element is a string of the form:
          'yyyy mm dd hh METAR'

        """
        # Validate the common station name and convert it to the
        # corresponding official station ID
        try:
            stn = self.stns[stn]
        except:
            raise UnknownStationError, stn
        # Process the date components in the keyword args into
        # instance attribute values
        for kw in kwargs:
            if kw in ('year', 'month', 'day'):
                self.__dict__[kw] = kwargs[kw]
            else:
                raise UnknownParameterError, (kw, kwargs[kw])
        # Get the list of METARs
        try:
            self.data = self._get_metars(stn, retries)
        except:
            raise
        # Validate and clean up the METAR data
        try:
            self._clean_data(stn, ignore_errors)
        except:
            raise
        return self.data


    def _get_metars(self, stn, retries):
        """Return the METAR data page as a list of strings.

        """
        # Build the URL parameter string.  Note that order of the
        # parameters apparently matters to vortex.plymouth.edu, so we
        # can't use urllib.urlencode()
        params = '='.join(('ident', stn))
        params += '&' + '='.join(('pl', 'none0'))
        params += '&' + '='.join(('yy', str(self.year)[-2:]))
        params += '&' + '='.join(('mm', '%02d' % self.month))
        params += '&' + '='.join(('dd', '%02d' % self.day))
        # Open the URL, and read it into a list of strings
        attempt = 0
        while attempt <= retries:
            try:
                page =  urllib.urlopen("%s?%s" %
                                       (self.site, params)).readlines()
            except:
                raise
            # If missing data are detected, try reading from the URL
            # again because sometimes the SFC_parse_file errors are
            # resolved on subsequent attempts
            if not [line for line in page
                    if line.startswith("SFC_parse_file:")]:
                return page
            else:
                attempt += 1
        else:
            # Return the data we got with a warning that some are
            # missing
            sys.stderr.write('server timeout: some data are missing '
                             'for %4i-%02i-%02i\n'
                             % (self.year, self.month, self.day))
            return page


    def _clean_data(self, stn, ignore_errors):
        """Validate and clean up the METAR data.

        """
        # Confirm that we got some data, and confirm that it's the
        # expected web page by checking the <title> tag contents
        if (not self.data) | (not self.data[0].startswith(
            '<TITLE>Generate WXP 24-Hour Meteogram</TITLE>')):
            if ignore_errors:
                sys.stderr.write('Invalid data returned for '
                                 '%4i-%02i-%02i\n'
                                 % (self.year, self.month, self.day))
                self.data = ''
                return
            else:
                raise UnexpectedPageError
        # Get rid of the <title> and <pre> tag lines
        self.data = self.data[2:]
        # Confirm that data is available for the specified date
        if self.data[0].startswith('No data were found for date'):
            if ignore_errors:
                sys.stderr.write('%4i-%02i-%02i data missing\n'
                                 % (self.year, self.month, self.day))
                self.data = ''
                return
            else:
                raise UnexpectedPageError
        #Get rid of the station location and following blank line
        self.data = self.data[2:]
        # Confirm that we got the data for the expected station by
        # checking the "METAR Data for" line contents
        if not self.data[0].startswith(
            ' '.join(("METAR Data for", stn))):
            if ignore_errors:
                sys.stderr.write('%4i-%02i-%02i data missing '
                                 'or incorrect station returned\n'
                                 % (self.year, self.month, self.day))
                self.data = ''
                return
            else:
                raise UnexpectedPageError
        # Get rid of the "METAR Data for" line and following blank
        # line
        self.data = self.data[2:]
        # Date part of timestamp for each line of data
        datestamp = '%4i %02i %02i' % (self.year, self.month, self.day)
        # Clean up each line
        i = 0
        try:
            while True:
                # Continuations from the previous line start with 5
                # spaces
                if self.data[i].startswith(' '*5):
                    # Concatenate continuation to previous line
                    self.data[i-1] = ' '.join((self.data[i-1][:-1],
                                               self.data[i][5:]))
                    # Get rid of continuation text that we just consumed
                    self.data.pop(i)
                # Get rid of file parse error lines
                if self.data[i].startswith('SFC_parse_file:'):
                    self.data.pop(i)
                    continue
                # Get rid of SPECI prefix
                if self.data[i].startswith('SPECI'):
                    self.data[i] = self.data[i][6:]
                fields = self.data[i].split()
                # Add METAR prefix if it's missing
                if fields[0] != 'METAR':
                    fields.insert(0, 'METAR')
                    self.data[i] = ' '.join(('METAR', self.data[i]))
                # Add hour to timestamp, and prepend timestamp to line
                self.data[i] = ' '.join((datestamp, fields[2][2:4],
                                         self.data[i]))
                # Get rid of duplicate data lines
                if self.data[i] == self.data[i-1]:
                    self.data.pop(i)
                    continue
                i += 1
        except IndexError:
            # No more data lines
            pass


def parse_options():
    """Parse the command line options.

    """

    # Build the option parser
    from optparse import OptionParser
    desc = ("Retrieve the METAR data for the specified station "
            "and date range and write it to stdout.")
    parser = OptionParser(description=desc)
    parser.usage += ' station'
    help = "beginning date for METAR data; default=yesterday"
    parser.add_option('-b', '--begin', help=help,
                      dest='begin', metavar='yyyy-mm-dd')
    help = "ending date for METAR data; default=yesterday"
    parser.add_option('-e', '--end', help=help,
                      dest='end', metavar='yyyy-mm-dd')
    help = "ignore missing date error, just flag them; default=False"
    parser.add_option('-i', '--ignore_errors', help=help,
                      action='store_true', dest='ignore_errors',
                      default=False)
    help = "number of retries if METAR server times out; default=5"
    parser.add_option('-r', '--retries', help=help,
                      action='store', type='int', dest='retries',
                      default=5)
    help = "run module doctest unit tests"
    parser.add_option('-t', '--test', help=help,
                      action='store_true', dest='doctest', default=False)
    help = "be verbose in output from unit tests"
    parser.add_option('-v', '--verbose', help=help,
                      action='store_true', dest='verbose', default=False)
    # Parse the command line options
    options, args = parser.parse_args()
    # Print help message if there is not exactly 1 command line
    # argument
    if len(args) != 1:
        parser.print_help()
        raise WrongNumberOfArguments, "\n\nToo few or too many arguments"
    if options.end and not options.begin:
        raise EndDateWithoutBeginError
    return options, args[0]


def _test(verbose):
    import doctest
    doctest.testmod(exclude_empty=True, verbose=verbose)


def metar_data(station, begin, end, ignore_errors, retries):
    """Return the METAR data for the specified station and date range.

    """

    def _parse_date(date_str):
        """Minimal date parser."""
        yr, mo, day = [int(x) for x in date_str.split('-')]
        try:
            return date(yr, mo, day)
        except ValueError:
            raise InvalidDateError, begin
        
    metar = METARdata()
    # Validate the beginning and end dates
    if not begin:
        return metar.get_met_data(station, ignore_errors, retries)
    else:
        date1 = _parse_date(begin)
    if not end:
        date2 = (datetime.today() - timedelta(days=1)).date()
    else:
        date2 = _parse_date(end)
    if date1 > date2:
        raise EndDateBeforeBeginError, (begin, end)
    # Retrieve the METAR data for the date range
    metars = []
    while date1 <= date2:
        metars.extend(metar.get_met_data(station, ignore_errors, retries,
                                         year=date1.year, month=date1.month,
                                         day=date1.day))
        date1 += timedelta(days=1)
    return metars


def main():
    # Parse the command line
    options, station = parse_options()
    # Run the unit tests, if requested
    if options.doctest:
        _test(options.verbose)
        return
    # Retrieve the list of METAR data for the specified station and
    # date range and write it to stdout
    print ''.join(metar_data(station, options.begin, options.end,
                             options.ignore_errors, options.retries)),


if __name__ == "__main__":
    main()

# end of file
