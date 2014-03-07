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
            'data_type',
            choices=('meteo', 'wind', 'river'),
            help='type of forcing data file',
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
        if parsed_args.chunk_suffix is not None:
            chunk_suffix = parsed_args.chunk_suffix
        date_readers = {
            'meteo': self._meteo_read_date,
            'wind': self._wind_read_date,
        }
        read_date = date_readers[parsed_args.data_type]
        for year in range(parsed_args.start_year, parsed_args.end_year):
            first_day = arrow.get(year, 1, 1)
            last_day = arrow.get(year + 2, 1, 1)
            chunk_lines = []
            with open(parsed_args.file, 'rt') as data:
                interesting_lines = self._interesting(
                    data, first_day, last_day, read_date
                )
                for line in interesting_lines:
                    chunk_lines.append(line)
            try:
                first_data_date = read_date(chunk_lines[0])
                last_data_date = read_date(chunk_lines[-1])
            except IndexError:
                self.log.warning(
                    'No {first_year}/{last_year} data'
                    .format(
                        first_year=first_day.year,
                        last_year=last_day.year - 1))
                continue
            if first_data_date != first_day or last_data_date != last_day:
                self.log.warning(
                    '{first_year}/{last_year} data is incomplete - no output'
                    .format(
                        first_year=first_day.year,
                        last_year=last_day.year - 1))
                continue
            if parsed_args.chunk_suffix is None:
                chunk_suffix = (
                    '_{first_year}{second_year}'
                    .format(
                        first_year=str(year)[-2:],
                        second_year=str(year + 1)[-2:]))
            chunk_file = ''.join((parsed_args.file, chunk_suffix))
            with open(chunk_file, 'wt') as output:
                    output.writelines(chunk_lines)
            self.log.info('Wrote {chunk_file}'.format(chunk_file=chunk_file))

    def _interesting(self, data, first_day, last_day, read_date):
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

    def _wind_read_date(self, line):
        day, month, year, remainder = line.split(maxsplit=3)
        data_date = arrow.get(*map(int, (year, month, day)))
        return data_date
