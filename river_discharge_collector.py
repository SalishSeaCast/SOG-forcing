#!/usr/bin/env python
"""River discharge (flow) data collector for sog-forcing.

This script returns the average discharge [m^3/s] of a specified river
at a specified measurement station on a specified day.  It captures
the discharge graph image from the Environment Canada Real-Time
Hydrometric Data site
(http://scitech.pyr.ec.gc.ca/waterweb/fullgraph.asp) and does some
elementary image processing on it to extract the average discharge for
the date rquested.

See:
      ./river_discharge_collector.py -h
for usage.

Author: Doug Latornell
Created: 2008-01-01
Last Revision $Date$ [UTC]
$Revision$
"""

# $Id$

__author__ = "Doug Latornell"
__email__ = "doug-code at sadahome dot ca"
__version__ = "$Revision$"[11:-2]


# Standard libarary modules:
from operator import itemgetter


# Exceptions:
class RiverException(Exception): pass
class UnknownRiverStation(RiverException): pass
class AmbiguousRiverStation(RiverException): pass


class River:
    """
    """

    # Map informal river monitoring station names to their official
    # names and station IDs.
    stations = [dict(informal_name="Fraser at Hope",
                     stnID="08MF005",
                     station_name="FRASER RIVER AT HOPE (08MF005)"),
                dict(informal_name="Englishman at Parksville",
                     stnID="08HB002",
                     station_name="ENGLISHMAN RIVER NEAR PARKSVILLE (08HB002)")]


    def __init__(self, station):
        """
        """
        name = itemgetter('informal_name')
        stn = [s for s in self.__class__.stations if name(s) == station]
        if not stn:
            raise UnknownRiverStation, station
        if len(stn) > 1:
            raise AmbiguousRiverStation, station
        self.stnID = stn[0]['stnID']
        self.station_name = stn[0]['station_name']


# end of file
