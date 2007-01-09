"""
Retrieve and process Environment Canada climate data from their web
site.

Functions:

- `get_data()`: description


Tests and Examples
------------------

Create an instance:
>>> ecdata = ECClimateData()
>>> ecdata.site
'http://www.climate.weatheroffice.ec.gc.ca/climateData/bulkdata_e.html'
>>> assert(date(year=ecdata.year, month=ecdata.month, day=ecdata.day)
...        == date.today() - timedelta(days=1))
>>> (ecdata.type, ecdata.format)
('hly', 'xml')
>>> print ecdata.stns['yvr']['name'], ecdata.stns['yvr']['stationID']
VANCOUVER INT'L A 889

>>> ecdata.get_data('yvr')

Raise a key error from get_data():
>>> ecdata.get_data('yvr', spam=42)
Traceback (most recent call last):
    ...
SystemExit: unknown parameter: spam=42

"""

__author__ = 'Doug Latornell'
__version__ = '$Id$'
__docformat__ = 'restructuredtext'


from datetime import date, datetime, timedelta
import sys
import urllib


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


    def get_data(self, stn, **kwargs):
        """

        """
        param_map = dict(stationID=self.stns[stn]['stationID'],
                         year=self.year, month=self.month, day=self.day,
                         type=self.type, format=self.format)
        for k in kwargs:
            if k in param_map:
                if kwargs[k] is None:
                    del param_map[k]
                else:
                    param_map[k] = kwargs[k]
            else:
                sys.exit("unknown parameter: %s=%s" % (k, str(kwargs[k])))
        params = urllib.urlencode(param_map)
        f = urllib.urlopen("%s?%s" % (self.site, params))
        return f.readline()

def _test():
    import doctest
    doctest.testmod()

if __name__ == "__main__":
    _test()

# end of file
