	     Lower Boundary Condition Values for SOG Code
			     10-Aug-2006


bottomP.dat is a data file of salinity, temperature, phytoplankton
biomass, and nitrate concentration values on various year-days that
Kate Collins constructed for the SOG code.

fitbottom.py is a Python script that uses the SciPy optimize.leastsq()
function to fit an annual variation model to data for the lower
boundary condition of the SOG bio-physical model of the Strait of
Georgia.  It reads salinity, temperature, phytoplankton biomass, and
nitrate concentration time series from bottomP.dat.  For each
quantity, we fit (in a least squares sense) 

Q = A + B * cos(arg) + C * sin(arg) + D * cos(2 * arg) + E * sin(2 * arg)

to the data, where arg = 2 * pi * yearday / 365.

# end of file
