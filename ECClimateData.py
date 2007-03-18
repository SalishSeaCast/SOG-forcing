#!/usr/bin/env python
"""
Retrieve and process Environment Canada climate data from their web
site.

Exception Classes:

- `ECClimateDataError`
- `UnknownParameterError`
- `InvalidNoneParameterError`
- `IncorrectStationError`
- `UnknownParameterError`

Functions:

- `get_met_data()`: Return a list of string of meteorological data for
  the specified station.


Tests and Examples
------------------

Create an instance and check the default property values:
  >>> ecdata = ECClimateData()
  >>> ecdata.site
  'http://www.climate.weatheroffice.ec.gc.ca/climateData/bulkdata_e.html'
  >>> assert(date(year=ecdata.year, month=ecdata.month, day=ecdata.day)
  ...        == date.today() - timedelta(days=1))
  >>> (ecdata.type, ecdata.format)
  ('hly', 'xml')
  >>> print ecdata.stns['yvr']['name'], ecdata.stns['yvr']['stationID']
  VANCOUVER INT'L A 889

Get 1 line of met data:
  >>> ecdata.site = 'test.xml'
  >>> print ecdata.get_met_data('yvr', year=2007, month=1, day=1)[0]
  2007 1 1 0  5.5 80.00 10

Get 1 line of wind data:
  >>> ecdata.site = 'wind.xml'
  >>> print ecdata.get_wind_data('sandheads', 55, year=2006, month=4, day=1)[0]

Test exceptions:
  >>> ecdata.get_met_data('yvr', spam=42)
  Traceback (most recent call last):
      ...
  UnknownParameterError: ('spam', 42)

  >>> ecdata.get_met_data('yvr', year=None)
  Traceback (most recent call last):
      ...
  InvalidNoneParameterError

  >>> ecdata.site = 'http://www.climate.weatheroffice.ec.gc'
  >>> ecdata.get_met_data('yvr')
  Traceback (most recent call last):
      ...
  IOError: [Errno 2] No such file or directory: 'http://www.climate.weatheroffice.ec.gc'

"""

__author__ = 'Doug Latornell'
__version__ = '$Id$'
__docformat__ = 'restructuredtext'


from datetime import date, datetime, timedelta
import math
import sys
import urllib
import xml.dom.minidom


class ECClimateData:

    """Retrieve and process Environment Canada climate data from their
    web site.

    """

    def __init__(self):
        """
        Initialize an `ECClimateData` object; set default property values.

        """
        self.site = ('http://www.climate.weatheroffice.ec.gc.ca/'
                     + 'climateData/bulkdata_e.html')
        """Root of URL to query for data."""
        yesterday = datetime.now() - timedelta(days=1)
        self.year = yesterday.year
        """Year to get data for."""
        self.month = yesterday.month
        """Month to get data for."""
        self.day = yesterday.day
        """Day to get data for."""
        self.type = 'hly'
        """Type of data to get (frequnecy)."""
        self.format = 'xml'
        """Format to retrieve data in."""
        self.stns = dict(yvr=dict(name="VANCOUVER INT'L A",
                                  stationID=889),
                         sandheads=dict(name="SANDHEADS CS",
                                        stationID=6831))
        """Mapping of common station names to official names, and
        station ID numbers."""
        

    def get_met_data(self, stn, **kwargs):
        """Return a list of string of meteorological data for the
        specified station.

        Each list element is a string of the form:
          'yyyy mm dd hh temperature humidity prelim_cloud_fraction'

        """
        try:
            dom = self._get_dom(stn, kwargs)
        except:
            raise
        self._check_stn(stn, dom)
        stndata = dom.getElementsByTagName('stationdata')
        data = []
        for node in stndata:
            tempdata = node.getElementsByTagName('temp')[0]
            humidity = node.getElementsByTagName('relhum')[0]
            weather = node.getElementsByTagName('weather')[0]
            weather = self._getText(weather.childNodes)
            try:
                data.append(' '.join((node.getAttribute('year'),
                                      node.getAttribute('month'),
                                      node.getAttribute('day'),
                                      node.getAttribute('hour'),
                                      self._getText(tempdata.childNodes),
                                      self._getText(humidity.childNodes),
                                      self._est_cloudfrac(weather))))
            except:
                raise
        return data


    def _est_cloudfrac(self, weather):
        """Map weather description to preliminary cloud fraction value.

        Weather description is a text string.  We return a
        corresponding preliminary cloud fraction value in the rannge 0
        to 10.

        """
        cloudfrac_map = {'clear':0,
                         'cloudy':10,
                         'drizzle':10,
                         'fog':10,
                         'mainly clear':4,
                         'moderate rain':10,
                         'moderate snow':10,
                         'mostly cloudy':7,
                         'rain':10,
                         'rain,fog':10,
                         'rain showers':10,
                         'rain showers,snow showers':10,
                         'snow':10,
                         'snow grains':10,
                         'snow showers':10,
                         }
        try:
            return unicode(cloudfrac_map[weather.lower()])
        except KeyError:
            raise UnknownWeatherDescriptionError, weather
        

    def get_wind_data(self, stn, angle, **kwargs):
        """Return a list of string of wind data for the specified
        station.

        Each list element is a string of the form:
          'yyyy mm dd hh u_windspeed v_windspeed'
          
        The wind speeds are in m/s.  The +u direction is to the east,
        and the +v direction is to the north (oceanographic
        convention).  The components are rotated through the specified
        angle (clockwise).

        """
        try:
            dom = self._get_dom(stn, kwargs)
        except:
            raise
        self._check_stn(stn, dom)
        stndata = dom.getElementsByTagName('stationdata')
        data = []
        for node in stndata:
            windspd = node.getElementsByTagName('windspd')[0]
            windspd = float(self._getText(windspd.childNodes))
            winddir = node.getElementsByTagName('winddir')[0]
            winddir = float(self._getText(winddir.childNodes))
            wind = self._calc_wind(windspd, winddir, angle)
            try:
                data.append(' '.join((node.getAttribute('year'),
                                      node.getAttribute('month'),
                                      node.getAttribute('day'),
                                      node.getAttribute('hour'),
                                      wind[0], wind[1])))
#                                      unicode(windspd), unicode(winddir))))
                                      
            except:
                raise
        return data


    def _calc_wind(self, windspd, winddir, angle):
        """

        """
        # Convert wind speed from km/hr to m/s, and direction from 10s
        # of degrees to degrees
        windspd = windspd * 1000 / 3600
        winddir = winddir * 10
        # Decompose the wind into components from the east and north
        u = windspd * math.sin(winddir * (math.pi / 180))
        v = windspd * math.cos(winddir * (math.pi / 180))
        # Calculate rotated wind components
        theta = -angle * math.pi / 180
        u = u * math.cos(theta) - v * math.sin(theta)
        v = u * math.sin(theta) + v * math.cos(theta)
        # Change wind to "from" direction
        u = -u
        v = -v
        return unicode(u), unicode(v)
    

    def _get_dom(self, stn, kwargs):
        """Return an xml.dom.minidom object contining the specified
        climate data.

        For testing purposes a local file may be specified.  It will
        be opened iff the opening the url fails.

        """
        # URL parameters and values
        param_map = dict(stationID=self.stns[stn]['stationID'],
                         year=self.year, month=self.month, day=self.day,
                         type=self.type, format=self.format)
        # Process args into parameter map
        for k in kwargs:
            if k in param_map:
                if kwargs[k] is None:
                    if kwargs[k] == 'day':
                        del param_map[k]
                    else:
                        raise InvalidNoneParameterError, kwargs[k]
                else:
                    param_map[k] = kwargs[k]
            else:
                raise UnknownParameterError, (k, kwargs[k])
        params = urllib.urlencode(param_map)
        # Open the URL (or test file), an dparse it into a minidom
        # object
        try:
            f = urllib.urlopen("%s?%s" % (self.site, params))
        except:
            try:
                f = open(self.site, 'r')
            except:
                raise
        dom = xml.dom.minidom.parse(f)
        f.close()
        return dom
            

    def _check_stn(self, stn, dom):
        """Confirm that the data returned is for the requested
        station.

        """
        stninfo = dom.getElementsByTagName('stationinformation')
        stnname = stninfo[0].getElementsByTagName('name')[0].childNodes
        if self._getText(stnname) != self.stns[stn]['name']:
            raise IncorrectStationError, (stn, self._getText(stnname))
        

    def _getText(self, nodelist):
        """Return the text from the specified nodes as a string."""
        rc = ''
        for node in nodelist:
            if node.nodeType == node.TEXT_NODE:
                rc = rc + node.data
        return rc


class ECClimateDataError(Exception): pass
class UnknownParameterError(ECClimateDataError): pass
class InvalidNoneParameterError(ECClimateDataError): pass
class IncorrectStationError(ECClimateDataError): pass
class UnknownWeatherDescriptionError(ECClimateDataError): pass
    

def _test():
    import doctest
    doctest.testmod()

if __name__ == "__main__":
    _test()

# end of file
