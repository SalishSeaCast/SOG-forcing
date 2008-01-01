#!/usr/bin/env python
"""Unit tests for river_discharge_collector.py script.

See:
    ./test-river_discharge_collector.py -h
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


# Standard library modules:
import unittest
from optparse import OptionParser
from pprint import pprint
# Module we're testing
import river_discharge_collector as rdc


class TestRiver(unittest.TestCase):
    """Unit tests for River object.
    """
    def test_init(self):
        """River object has stnID and station_name
        """
        river = rdc.River('Fraser at Hope')
        self.failUnless(river.stnID == '08MF005')
        self.failUnless(river.station_name == "FRASER RIVER AT HOPE (08MF005)")
        river = rdc.River("Englishman at Parksville")
        self.failUnless(river.stnID == "08HB002")
        self.failUnless(river.station_name ==
                        "ENGLISHMAN RIVER NEAR PARKSVILLE (08HB002)")
        self.failUnlessRaises(rdc.UnknownRiverStation,
                              rdc.River, 'spam')


def _build_parser():
    """Command line parser for running tests.
    """
    parser = OptionParser()
    parser.description = "Unit test code for river_discharge_selector script."
    parser.add_option('-v', '--verbose', action='store_true',
                      dest='verbose', default=False,
                      help='print test descriptions as they are run')
    return parser

        
if __name__ == '__main__':
    # Parse the command line
    parser = _build_parser()
    options, args = parser.parse_args()
    # Build the test suite
    suite = unittest.TestLoader().loadTestsFromTestCase(TestRiver)
    # Execute the tests with requested verbosity
    verbosity = 1
    if options.verbose:
        verbosity = 2
    unittest.TextTestRunner(verbosity=verbosity).run(suite)
