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

import arrow
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
            '-e', '--end-year',
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
        if parsed_args.end_year is None:
            parsed_args.end_year = parsed_args.start_year + 1
        for year in range(parsed_args.start_year, parsed_args.end_year):
            if parsed_args.chunk_suffix is not None:
                chunk_suffix = parsed_args.chunk_suffix
            else:
                chunk_suffix = (
                    '_{first_year}{second_year}'
                    .format(
                        first_year=str(year)[-2:],
                        second_year=str(year + 1)[-2:]))
            chunk_file = ''.join((parsed_args.file, chunk_suffix))
            with open(parsed_args.file, 'rt') as data:
                with open(chunk_file, 'wt') as output:
                    for line in self._interesting(data, year):
                        output.write(line)

    def _interesting(self, data, first_year):
        first_day = arrow.get(first_year, 1, 1)
        last_day = arrow.get(first_year + 2, 1, 1)
        read_date = self._meteo_read_date
        for line in data:
            data_date = read_date(line)
            if data_date >= first_day and data_date <= last_day:
                yield line
            if data_date > last_day:
                raise StopIteration

    def _meteo_read_date(self, line):
        stn, year, month, day, remainder = line.split(maxsplit=4)
        data_date = arrow.get(*map(int, (year, month, day)))
        return data_date
