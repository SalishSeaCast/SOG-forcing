program format_eng

! program to take data format from website into format for the file
! process file to a) change ^M to return and b) change blanks for none existing
! days (eg Feb 30) to -99 c) remove data codes

!** change year as necessary by search and replace... current year is 2003

  implicit none
  integer day, i, j
  real :: english(31,12)

  open (11, file="english2003.dat")

! skip header line
  read (11,*)

  do i=1,31
     read (11,*) day, (english(i,j),j=1,12)
  enddo

  do j=1,12
     do i=1,31
        if (english(i,j) /= -99) then
           write (*,101) j, i, english(i,j)
0101       format ('2003 ',i2,' ',i2,' ',e13.4)
        endif
     enddo
  enddo

end program format_eng

