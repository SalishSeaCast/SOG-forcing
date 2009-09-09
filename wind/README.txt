		       Susan's 18-Jul-06 Notes

Two raw datafiles came from
/ocean/shared/SoG/met_data/sand_sept2001-apr2006.mat and
from/ocean/kcollins/sog/input/wind/wind.mat in Jun 2006.

The data for early 2001 comes from SH.dat from Roy Hourston and Rick
Thomson.  The original file is SH.dat and the SH.str file is created
in emacs by removing the header, changing / to two blanks, : to two
blanks and two blanks nan to -99

Now another correction: the data from
/ocean/shaared/SoG/met_data/sand_sept2001-apr2006.mat are wrong for
Apr 5 to Jul 1 as they come from Entrance Island rather than
Sandheads.  Got the raw data, converted it to .mat file and then
insert it into data in CompositeWind.m


			Doug's 28-Jul-06 Notes

The SHcompRot.dat file was process with the
sog-forcing/formatDataFile.py script to reformat its data correctly as
integers and e-notation reals.  The command used was:

../formatDataFile.py "%i %i %i %e %e %e" <SHcompRot.dat >SHcompRotFmt.dat


		     Megan's 05-Feb-08 Notes

The SH_total.dat file is the historical data from SH_historic.dat which 
ranges from May 1,1967 to Sep 1, 2001 plus the SHcompRot.dat which includes 
data from 2001 to April 2006.  The SH_historic.dat is the data from SH.dat but
formatted to be like SHcompRot.dat.  SH_historic.dat was shifted by 8 hrs, so I
shifted it back to fit the SHcompRotFmt.dat time.
		   
		  
		  Megan's Aug - 2009 notes

The rI_Winds.txt file contains wind data for Rivers Inlet. This data was derived using a formala in pH_windFormula.f90.  Using wind data from Port Hardy, we determined a formula to calculate whether the wind would be going up or down channeel in rivers Inlet.  DF02 is located in a part of Rivers inlet that runs due north/south and the larger winds tend to be channeled either up or down channel.  Running matlab code windComparison_laska.m shows wind direction/speed comparisonsof port hardy and laska (Mike's Weather station). 

# end of file

