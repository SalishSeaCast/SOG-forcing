#!/usr/bin/env python
"""
Retrieve and process METAR weather data from the Plymouth State
University archive site (vortex.plymouth.edu).

Exception Classes:

- `METARDataError'
- `UnknownParameterError`
- `UnknownStationError`
- `UnexpectedPageError`
- `InvalidDateError`

Functions:

- `get_met_data()`: Return a list of string of meteorological data for
  the specified station.


Tests and Examples
------------------

Create an instance and check the default property values:
  >>> metar = METARdata()
  >>> metar.site
  'http://vortex.plymouth.edu/cgi-bin/gen_statlog-u.cgi'
  >>> assert(date(year=metar.year, month=metar.month, day=metar.day)
  ...        == date.today() - timedelta(days=1))
  >>> print metar.stns['yvr'], metar.stns['sandheads']
  CYVR CWVF

  >>> print metar.get_met_data('yvr', year=2007, month=4, day=1)

Test exceptions:
  >>> metar.get_met_data('yvr', spam=42)
  Traceback (most recent call last):
      ...
  UnknownParameterError: ('spam', 42)
  
  >>> metar.get_met_data('yyz')
  Traceback (most recent call last):
      ...
  UnknownStationError: yyz

"""

__author__ = 'Doug Latornell'
__version__ = '$Id$'
__docformat__ = 'restructuredtext'


from datetime import date, datetime, timedelta
import urllib


# Exceptions:
class METARDataError(Exception): pass
class UnknownParameterError(METARDataError): pass
class UnknownStationError(METARDataError): pass
class UnexpectedPageError(METARDataError): pass
class InvalidDateError(METARDataError): pass
class EndDateWithoutBeginError(METARDataError): pass
    

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
        

    def get_met_data(self, stn, **kwargs):
        """Return a list of strings of meteorological data for the
        specified station.

        Each list element is a string of the form:
          'yyyy mm dd hh METAR'

        """
        try:
            self.data = self._get_metars(stn, kwargs)
        except:
            raise
        # Validate and clean up the METAR data
        try:
            self._clean_data(stn)
        except:
            raise
        return self.data


    def _clean_data(self, stn):
        """Validate and clean up the METAR data.

        """
        # Confirm that we got the expected web page by checking the
        # <title> tag contents
        if not self.data[0].startswith(
            '<TITLE>Generate WXP 24-Hour Meteogram</TITLE>'):
            raise UnexpectedPageError
        # Get rid of the <title> and <pre> tag lines, and the station
        # location and following blank line
        self.data = self.data[4:]
        # Confirm that we got the data for the expected station by
        # checking the "METAR Data for" line contents
        if not self.data[0].startswith(
            ' '.join(("METAR Data for", self.stns[stn]))):
            raise UnexpectedPageError
        # Get rid of the "METAR Data for" line and following blank
        # line
        self.data = self.data[2:]
        # Date part of timestamp for each line of data
        datestamp = '%4i %02i %02i' % (self.year, self.month, self.day)
        #
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
                i += 1
        except IndexError:
            pass


    def _get_metars(self, stn, kwargs):
        """Return the METAR data page as a list of strings.

        """
        # URL parameters and values
        try:
            param_map = dict(stn=self.stns[stn], plots='none0',
                             year=self.year, month=self.month, day=self.day)
        except:
            raise UnknownStationError, stn
        # Process args into parameter map
        for kw in kwargs:
            if kw in param_map:
                param_map[kw] = kwargs[kw]
            else:
                raise UnknownParameterError, (kw, kwargs[kw])
        # Build the parameter string.  Note that order of the
        # parameters apparently matters to vortex.plymouth.edu, so we
        # can't use urllib.urlencode()
        params = '='.join(('ident', param_map['stn']))
        params += '&' + '='.join(('pl', param_map['plots']))
        params += '&' + '='.join(('yy', str(param_map['year'])[-2:]))
        params += '&' + '='.join(('mm', '%02d' % param_map['month']))
        params += '&' + '='.join(('dd', '%02d' % param_map['day']))
        # Open the URL, and read it into a list of strings
        try:
            return urllib.urlopen("%s?%s" % (self.site, params)).readlines()
        except:
            raise


def parse_options():
    """Parse the command line options.

    """

    # Build the option parser
    from optparse import OptionParser
    desc = ' '.join(("Retrieve the METAR data for the specified station",
                     "and date range and write it to stdout."))
    parser = OptionParser(description=desc)
    parser.usage += ' station'
    help = "beginning date for METAR data; default=yesterday"
    parser.add_option('-b', '--begin', help=help,
                      dest='begin', metavar='yyyy-mm-dd')
    help = "ending date for METAR data; default=yesterday"
    parser.add_option('-e', '--end', help=help,
                      dest='end', metavar='yyyy-mm-dd')
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
    if len(args) != 1 or (options.end and not options.begin):
        parser.print_help()
        raise EndDateWithoutBeginError
    return options, args[0]


def _test(verbose):
    import doctest
    doctest.testmod(exclude_empty=True, verbose=verbose)


def metar_data(station, begin, end):
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
        return metar.get_met_data(station)
    else:
        date1 = _parse_date(begin)
    if not end:
        date2 = (datetime.today() - timedelta(days=1)).date()
    else:
        date2 = _parse_date(end)
    # Retrieve the METAR data for the date range
    metars = []
    while date1 <= date2:
        metars.extend(metar.get_met_data(station, year=date1.year,
                                         month=date1.month, day=date1.day))
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
    print ''.join(metar_data(station, options.begin, options.end))


if __name__ == "__main__":
    main()

# end of file
