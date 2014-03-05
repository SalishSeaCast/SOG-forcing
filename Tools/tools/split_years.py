# Copyright 2006-2014 The University of British Columbia

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#    http://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

"""SOG-forcing_tools command plug-in to create by-year subsets
of SOG-forcing data files.
"""
import logging

import cliff.command


__all__ = ['SplitYears']


class SplitYears(cliff.command.Command):
    """Generate 2 yr long chunks from forcing data file.
    """
    log = logging.getLogger(__name__)

    def get_parser(self, prog_name):
        parser = super(SplitYears, self).get_parser(prog_name)
        parser.add_argument(
            'file',
            help='forcing data file to create 2-yr chunks from',
        )
        parser.add_argument(
            'start_year',
            type=int,
            help='starting year for first chunk',
        )
        parser.add_argument(
            '-e', '--end-date',
            type=int,
            help='ending year for last chunk; defaults to start_year + 1',
        )
        parser.add_argument(
            '--chunk-suffix',
            help="suffix for chunk file names; "
                 "defaults to _XXYY, where XX is the chunk's starting year, "
                 "and YY is the chunk's ending year; "
                 "e.g. _9293 for the 1992-1993 chunk",
        )
        return parser

    def take_action(self, parsed_args):
        pass
