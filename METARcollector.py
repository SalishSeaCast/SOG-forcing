#!/usr/bin/env python
"""
Retrieve and process METAR weather data from the Plymouth State
University archive site (vortex.plymouth.edu).

Exception Classes:

- `METARDataError'
- `UnknownParameterError`
- `UnknownStationError`
- `UnexpectedPageError`

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
        yesterday = datetime.now() - timedelta(days=1)
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
            self._clean_data()
        except:
            raise
        return self.data


    def _clean_data(self):
        """Validate and clean up the METAR data.

        """
        # Confirm that we got the expected web page by checking the
        # <title> tag contents
        if not self.data[0].startswith(
            '<TITLE>Generate WXP 24-Hour Meteogram</TITLE>'):
            raise UnexpectedPageError
        # Get rid of the <title> and <pre> tag lines
        self.data = self.data[2:]
        # 


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


# Exceptions:
class METARDataError(Exception): pass
class UnknownParameterError(METARDataError): pass
class UnknownStationError(METARDataError): pass
class UnexpectedPageError(METARDataError): pass
    

def _test():
    import doctest
    doctest.testmod()

if __name__ == "__main__":
    _test()

# end of file
