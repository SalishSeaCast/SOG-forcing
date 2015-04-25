program process

! read in the files that EC sent me in Aug 2010 and proces them to be like the previous files.  Basically reading in integers and putting out f5.1
! for Nov 2011 data, inserted spaces (insert rectangle) as required before running this.
! for April 2015 data, make it read without inserting the rectangle


  integer :: id, year,month,day,code
  real*8:: data(24)
  integer :: datai(24)

  npts = 874

  do i=1,npts
     read (*,101) id, year, month, day, code, datai
101  format (i7,i4,i2,i2,i3,i6,23(1x,i6))
     data = datai
     write (*,102) id, year, month, day, code, data
102 format (i7,1x,i4,1x,i2,1x,i2,1x,i2,1x,24(F8.1,1x))
  enddo

end program process
  
