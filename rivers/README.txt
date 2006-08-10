Fraser_flowDaily.csv downloaded from the Environment Canada web site
on August 9.  

Fraser_flowDaily.dat an emacs manipulation of that file to remove the
station information, the flow height, the '/' and the '^M'.

Fraser_2001_2005.dat a truncated version of that file that covers 2001
through 2005.

Englishman_flowDaily.csv downloaded from the Environment Canada web site
on August 9.

Englishman_flowDaily.dat an emacs manipulation of that file to remove the
station information, the '/' and the '^M'

As the Englishman data only goes to the end of 2004 at this point, I have
not made 2001_2005 files.  Continue to use eng200123456.dat for now.

Formatting in eng200123456.dat file was adjusted to make year, month,
and day fields integers, so that it can be read by SOG compiled with
g95.  The commands to do the reformatting are:

      ../formatDataFile "%i %i %i %e %e" < eng200123456.dat > spam
      mv spam eng2001223456.dat

# end of file

