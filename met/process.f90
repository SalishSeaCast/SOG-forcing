program process

! read in the files that EC sent me in Aug 2010 and proces them to be like the previous files.  Basically reading in integers and putting out f5.1
! for Nov 2011 data, inserted spaces (insert rectangle) as required before running this.


  integer :: id, year,month,day,code
  real*8:: data(24)
  integer :: datai(24)

  npts = 6570


  do i=1,npts
     read (*,*) id, year, month, day, code, datai
     data = datai
     write (*,101) id, year, month, day, code, data
101  format (i7,1x,i4,1x,i2,1x,i2,1x,i2,1x,24(F6.1,1x))
  enddo

end program process
  
