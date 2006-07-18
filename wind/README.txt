Two raw datafiles came from /ocean/shared/SoG/met_data/sand_sept2001-apr2006.mat and from/ocean/kcollins/sog/input/wind/wind.mat in Jun 2006.

the data for early 2001 comes from SH.dat from Roy Hourston and Rick Thomson.  The original file is SH.dat and the SH.str file is created in emacs by removing the header, changing / to two blanks, : to two blanks and two blanks nan to -99

Now another correction: the data from /ocean/shaared/SoG/met_data/sand_sept2001-apr2006.mat are wrong for Apr 5 to Jul 1 as they come from Entrance Island rather than Sandheads.  Got the raw data, converted it to .mat file and then insert it into data in CompositeWind.m
