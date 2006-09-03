#!/usr/bin/env python
"""Use SciPy optimize.leastsq to fit an annual variation model to data
for the lower boundary condition of the SOG bio-physical model of the
Strait of Georgia.

Salinity, temperature, phytoplankton biomass, and nitrate
concentration time series are read from bottomP.dat.
"""

# $Id$

# NumPy and SciPy modules:
from numpy import * 
from scipy import io
from scipy import optimize


def residual(y, qty, arg):
    """For each quantity, we want to fit:
    Q = A + B * cos(arg) + C * sin(arg) + D * cos(2 * arg) + E * sin(2 * arg)
    where arg = 2 * pi * yearday / 365.

    This is the function that calculates the residuals of the fit.

    """
    return -qty + y[0] + y[1] * cos(arg) + y[2] * sin(arg) \
           + y[3] * cos(2. * arg) + y[4] * sin(2. * arg)

# for just a seasonal fit
def seasonal(y, qty, arg):
    return -qty + y[0] + y[1] * cos(arg) + y[2] * sin(arg)

# for just a biseasonal fit
def biseasonal(y, qty, arg):
        return -qty + y[0] + y[1] * cos(2. * arg) + y[2] * sin(2. * arg)

# Open the data file, and read the quantities into numpy arrays
try:
    f = open('bottomP.dat', 'r')
except IOError:
    print 'Error: unable to read bottomP.dat'
    raise SystemExit
(sal, temp, phyto, junk, yearday) = \
      io.array_import.read_array(f, columns=[(0, ), (1, ), (2, ), (3, ),
                                             (4, )])
try:
    f = open('Nuts_bottom.txt', 'r')
except IOError:
    print 'Error: unable to read Nuts_bottom.txt'
    raise SystemExit
(cn, nitr, sil, ratio) = \
     io.array_import.read_array(f, columns=[(0, ), (1, ), (2, ), (3, )])
# For each quantity, we want to fit:
# Q = A + B * cos(arg) + C * sin(arg) + D * cos(2 * arg) + E * sin(2 * arg)
arg = 2 * pi * yearday / 365.
# Starting estimates for minimization
x0 = {'sal':array([29.7, 0.2, 0., 0., 0.]),
      'temp':array([9.4, 0.5, 0., 0., 0.]),
      'phyto':array([0.6, 0., 0., 0., 0.2]),
      'nitr':array([25., 0. ,0., 0., -3.0]),
      'sil':array([50.,0.,0.,0.,0.]),
      'ratio':array([0.,0.,0.,0.,0.])}
# Calculate the least squares fits of Q to the data
params = [('salinity:', sal, 'sal'),
          ('temperature:', temp, 'temp'),
          ('phytoplankton biomass:', phyto, 'phyto'),
          ('nitrate concentration:', nitr, 'nitr'),
          ('silicon concentration:', sil, 'sil'),
          ('ratio pico/micro:', ratio, 'ratio')]
for title, qty, i in params:
    args = (qty, arg)
    (x, msg) = optimize.leastsq(residual, x0[i], args=args)
    print '\n', title
    print x
    print msg
    print sqrt(sum(residual(x, qty, arg)**2))

# seasonal fit
x1 = {'sal':array([29.7, 0.2, 0.]),
      'temp':array([9.4, 0.5, 0.]),
      'phyto':array([0.6, 0., 0.]),
      'nitr':array([25., 0. ,0.]),
      'sil':array([50.,0.,0.]),
      'ratio':array([0.,0.,0.])}

for title, qty, i in params:
    args = (qty, arg)
    (x, msg) = optimize.leastsq(seasonal, x1[i], args=args)
    print '\n', title
    print x
    print msg
    print sqrt(sum(seasonal(x, qty, arg)**2))

# biseasonal fit for ratio
title = 'ratio pico/micro:'
x2 =  array([1.,0.5,0.5])
args = (ratio, arg)
(x, msg) = optimize.leastsq(biseasonal, x2, args=args)
print '\n', title
print x
print msg
print sqrt(sum(biseasonal(x, ratio, arg)**2))

# constant fit
for title, qty, i in params:
    args = (qty, arg)
    x = average(qty)
    print '\n', title
    print x
    print sqrt(sum((x-qty)**2))

# end of file
