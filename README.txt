formatDataFile.py 

   A script to filter a SOG forcing data file to change the format of
   the fields.  This script arises from the fact that g95 is stricter
   than pgf90 about free-format input.  For instance, data read into
   integer variable must be represented as integers (not reals) in the
   data file.  The Sand Heads wind data files wind/SH*.dat is an
   example of files that needed reformating.

# end of file
