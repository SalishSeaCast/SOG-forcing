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

import cliff.app
import pytest


@pytest.fixture
def split_years():
    import tools.split_years
    return tools.split_years.SplitYears(mock.Mock(spec=cliff.app.App), [])


def test_get_parser(split_years):
    parser = split_years.get_parser('tools 2yr_subset')
    assert parser.prog == 'tools 2yr_subset'
