program try

  open (11, file="pHt.txt")

! p is current value of port hardy direction
! pp is previous value of port hardy direction

! rt is current value (derived) for Laska direction
! rtp is previous value for Laska direction 

  read (11,*) t,p

  rt = 360

  write (*,101) t, p, rt

  read (*,*) npts
  do i=1,npts
     pp = p
     rp = r
     rtp = rt
     cn = 0
       read (11,*) t,p
       
       if (p<50) p = p + 360
       if (p<60) then
          if (abs(pp-p) < 5) then
             rt = 360
          else
             rt = rtp
          endif
       elseif (p<140) then
          rt = rtp
       elseif (p<150) then
          if (rtp < 180) then
             rt = 180
          else
             rt = rtp
          endif
       elseif (p<160) then
          rt = 180
       elseif (p<170) then
          rt = rtp
       elseif (p<180) then
          if (rtp<180) then
             rt =360
          else
             rt = rtp
          endif
       elseif (p<210) then
          rt = 360
       elseif (p<220) then
          if (abs(pp-p) < 5) then
             rt = 360
          elseif (pp < p) then
             rt = 180
          else
             rt = 360
          endif
       elseif (p<240) then
          rt = 180
       elseif (p<260)then
          rt = rtp
       elseif (p<280) then
          rt =360
       elseif (p<300) then
          rt = rtp
       elseif (p<310) then
          if (abs(pp-p) < 5) then
             rt = rtp
          elseif (pp>p) then
             rt = 180
          else
             rt = 360
          endif
       elseif (p<320) then
          if (abs(pp-p)<5) then
             rt = rtp
          elseif (pp>p) then
             rt = 180
          else
             rt = rtp
          endif
       elseif (p<390) then
             rt = 180          
       else
          rt = rtp
       endif
       !write (*,101) t-733834, p, pp, r, rp, rt, cn
       write (*,101) t, p, rt
       !open (unit=129, file="RI_windConversion.txt")
       !write (129,*)t, p, rt
       !close(129)

101 format (3x,7(e13.5,3x))
    enddo
  end program try 

