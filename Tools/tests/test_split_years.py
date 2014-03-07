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

"""Unit tests for split_years module.
"""
try:
    import unittest.mock as mock
except ImportError:  # pragma: no cover; happens for Python < 3.3
    import mock

import arrow
import cliff.app
import pytest


@pytest.fixture
def split_years():
    import tools.split_years
    return tools.split_years.SplitYears(mock.Mock(spec=cliff.app.App), [])


def test_get_parser(split_years):
    parser = split_years.get_parser('tools 2yr_subset')
    assert parser.prog == 'tools 2yr_subset'


@pytest.mark.parametrize(
    'start_yr, end_yr, expected',
    [
        (1992, None, 1993),
        (1992, 1995, 1995),
    ]
)
def test_take_action_end_year(start_yr, end_yr, expected, split_years):
    parsed_args = mock.Mock(
        file='foo',
        data_type='meteo',
        start_year=start_yr,
        end_year=end_yr,
        chunk_suffix=None,
    )
    m_open = mock.mock_open()
    with mock.patch('tools.split_years.open', m_open(), create=True):
        split_years.take_action(parsed_args)
    assert parsed_args.end_year == expected


@pytest.mark.parametrize(
    'start_yr, end_yr, chunk_suffix, expected',
    [
        (1992, None, None, ['_9293']),
        (1992, None, '_bar', ['_bar']),
    ]
)
def test_take_action_chunk_suffix(
    start_yr, end_yr, chunk_suffix, expected, split_years,
):
    parsed_args = mock.Mock(
        file='foo',
        data_type='meteo',
        start_year=start_yr,
        end_year=end_yr,
        chunk_suffix=chunk_suffix,
    )
    split_years.log = mock.Mock()
    split_years._interesting = mock.Mock(return_value=iter([
        '1108447 1992 1 1 foo\n',  # first day
        '1108447 1992 3 5 foo\n',  # day in range
        '1108447 1994 1 1 foo\n',  # end before last day
    ]))
    m_open = mock.mock_open()
    with mock.patch('tools.split_years.open', m_open, create=True):
        split_years.take_action(parsed_args)
    expected_calls = [mock.call('foo' + e, 'wt') for e in expected]
    assert m_open.call_args_list[1::2] == expected_calls
    expected_calls = [mock.call('Wrote foo' + e) for e in expected]
    split_years.log.info.call_args_list == expected_calls


def test_take_action_read_from_forcing_file(split_years):
    parsed_args = mock.Mock(
        file='foo',
        data_type='meteo',
        start_year=1992,
        end_year=None,
        chunk_suffix=None,
    )
    m_open = mock.mock_open()
    with mock.patch('tools.split_years.open', m_open, create=True):
        split_years.take_action(parsed_args)
    assert m_open.call_args_list[0] == [('foo', 'rt')]


def test_take_action_no_empty_output(split_years):
    parsed_args = mock.Mock(
        file='foo',
        data_type='meteo',
        start_year=1992,
        end_year=None,
        chunk_suffix=None,
    )
    split_years.log = mock.Mock()
    m_open = mock.mock_open()
    with mock.patch('tools.split_years.open', m_open, create=True):
        split_years.take_action(parsed_args)
    m_open.assert_called_once_with('foo', 'rt')
    split_years.log.warning.assert_called_once_with('No 1992/1993 data')


def test_take_action_no_incomplete_output(split_years):
    parsed_args = mock.Mock(
        file='foo',
        data_type='meteo',
        start_year=1992,
        end_year=None,
        chunk_suffix=None,
    )
    split_years.log = mock.Mock()
    split_years._interesting = mock.Mock(return_value=iter([
        '1108447 1992 1 1 foo\n',    # first day
        '1108447 1992 3 5 foo\n',    # day in range
        '1108447 1993 12 31 foo\n',  # end before last day
    ]))
    m_open = mock.mock_open()
    with mock.patch('tools.split_years.open', m_open, create=True):
        split_years.take_action(parsed_args)
    m_open.assert_called_once_with('foo', 'rt')
    split_years.log.warning.assert_called_once_with(
        '1992/1993 data is incomplete - no output')


@pytest.mark.parametrize(
    'data',
    [
        ['1108447 1992 1 1 foo\n'],  # first day
        ['1108447 1992 3 5 foo\n'],  # day in range
        ['1108447 1994 1 1 foo\n'],  # last day
    ]
)
def test_interesting_yield(data, split_years):
    first_day = arrow.get(1992, 1, 1)
    last_day = arrow.get(1994, 1, 1)
    read_date = split_years._meteo_read_date
    line = next(split_years._interesting(data, first_day, last_day, read_date))
    assert line == data[0]


@pytest.mark.parametrize(
    'data',
    [
        ['1108447 1991 1 1 foo\n'],  # all data before start year
        ['1108447 1994 1 2 foo\n'],  # day after last day to output
    ]
)
def test_interesting_stop_iteration(data, split_years):
    first_day = arrow.get(1992, 1, 1)
    last_day = arrow.get(1994, 1, 1)
    read_date = split_years._meteo_read_date
    with pytest.raises(StopIteration):
        next(split_years._interesting(data, first_day, last_day, read_date))


def test_meteo_read_date(split_years):
    line = '1108447 1991 1 1 foo\n'
    data_date = split_years._meteo_read_date(line)
    assert data_date == arrow.get(1991, 1, 1)


def test_wind_read_date(split_years):
    line = '08 02 2014 16.0 -0.435779 -4.980973\n'
    data_date = split_years._wind_read_date(line)
    assert data_date == arrow.get(2014, 2, 8)


def test_river_read_date(split_years):
    line = '  2012      7      1  10034\n'
    data_date = split_years._river_read_date(line)
    assert data_date == arrow.get(2012, 7, 1)
