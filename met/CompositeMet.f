c   program to merge data delivered to SEA and Kate's downloads of raw data 
c     (air temperature and humidity) and Doug's python read of raw data 
c     (cloud fraction)
c     compile with: pgf77 -o CompositeMet CompositeMet.f
c     run with: CompositeMet

      implicit none

      integer lotsofroom,nolines,nolines2,hoursperday
      parameter (lotsofroom=10000)
      parameter (nolines=4847, nolines2=1919,hoursperday=24)
      integer jan0101,toapril2,fromapril3
      parameter (jan0101=4019,toapril2=4840,fromapril3=823)
      integer stnno, year(lotsofroom), month(lotsofroom), 
     >     day(lotsofroom), data, hum(lotsofroom,hoursperday)
      real cstnno, cyear(nolines2), cmonth(nolines2), cday(nolines2), 
     >     cdata, chum(nolines2,hoursperday), thum(hoursperday)
      real store(hoursperday)
      integer count

c internal variabils
      integer idatatype ! 1 = humidity, 2 = air temp, 3 = cloud fraction
      integer i,ii ! counters to go through day
      integer j,k,m ! counters to go through hours
      integer ifiles ! to step through the different python generated files
      integer norecords ! to keep track of number of stored records from previous files
      integer flag ! marks end of file condition

      integer iyear,imonth,iday ! for use with shifting time of Kate's data
      real uhum ! to store a value

c all the variables in the code are called humidity but we are going to do it three times: humidity, temperature and cloud fraction.  Files read in for cf are different because Kate's reading of cloud fraction was inconsistent

      do idatatype=1,3

c     data from SEA

      if (idatatype.eq.1) then
         open (11,file='hum.dat')
      elseif (idatatype.eq.2) then
         open (11,file='atemp.dat')
      elseif (idatatype.eq.3) then
         open (11,file='cf.dat') 
      else
         write (*,*) 'Something wrong with idatatype'
         stop
      endif

       do i=1,nolines
          read (11,*) stnno,year(i),month(i),day(i),data,
     >         (hum(i,j),j=1,24)

c     for the future when we use a good year value. Repeat below after reading Kate's file
c          if (year(i).gt.100) then
c             year(i) = year(i) + 1000
c          else
c             year(i) = year(i) + 2000
c          endif
       enddo

       close (11)


c data from Kate
       
       if (idatatype.eq.1) then
          open (12,file='hum200123456.dat')
       elseif (idatatype.eq.2) then
          open (12,file='temp200123456.dat')
       elseif (idatatype.eq.3) then
          write (*,*) 'Using Dougs python cf read'
       else
          write (*,*) 'Something wrong with idatatype'
          stop
       endif

       if (idatatype.lt.3) then
          do i=1,nolines2
             read (12,*) cstnno,cyear(i),cmonth(i),cday(i),cdata,
     >            (chum(i,j),j=1,24)
          enddo
          
          close(12)
       else

c     read python read data for cf
         norecords = nolines
         do ifiles = 1, 5
            if (ifiles.eq.1) then
               open (12,file='cf20030402.dat')
            elseif (ifiles.eq.2) then
               open (12,file='cf20040701.dat')
            elseif (ifiles.eq.3) then
               open (12,file='cf20041001.dat')
            elseif (ifiles.eq.4) then
               open (12,file='cf20050405.dat')
            elseif (ifiles.eq.5) then
               open (12,file='cf20050701.dat')
            else
               write (*,*) 'something wrong with ifiles'
               stop
            endif
            flag = 0
            i = norecords+1
            do while (flag.eq.0)
               read (12,*,END=1001) stnno, year(i), month(i), day(i), 
     >              data, (hum(i,j),j=1,24) ! statement 1001 sets flag = 1
               do j=1,24
                  if (hum(i,j).eq.999) hum(i,j) = -99999
               enddo
               i = i + 1
               if (year(i-1).le.year(norecords)) then
                  if (month(i-1).le.month(norecords)) then
                     if (day(i-1).le.day(norecords)) then
                        i = i - 1 ! don't increment i, discard this record
                     endif
                  endif
               endif
 1002       enddo    ! end of file takes us back here after setting flat to 1
            close(12)
            norecords = i - 1
         enddo
      endif



c    write out combined data (this can be fixed in the future to give a better format)

       if (idatatype.eq.1) then
          open (13,file='YVRCombHum.dat')
       elseif (idatatype.eq.2) then
         open (13,file='YVRCombATemp.dat')
      elseif (idatatype.eq.3) then
         open (13,file='YVRCombCF.dat') 
      else
         write (*,*) 'Something wrong with idatatype'
         stop
      endif

c     go through direct cf/atemp/hum data and through python files to look for missing data

       if (idatatype.le.2) norecords = toapril2
      
       do i=jan0101,norecords

c     check data for missing values

          do j=1,24
             if (hum(i,j).eq.-99999) then
                if (j.ne.1.and.j.ne.24) then
                   if(hum(i,j-1).ne.-99999.and.hum(i,j+1).ne.-99999)then
                      thum(j) = 0.5*(hum(i,j-1)+hum(i,j+1))
                      write (*,*) year(i),month(i),day(i)
                   else
                      k = j
                      count = 1
                      ii = i
                      do while (hum(ii,k+1).eq.-99999)
                      k = k + 1
                      if (k.eq.24) then
                         ii = i + 1
                         k = 0
                      endif
                      count = count + 1
                      enddo
                      write (*,*) year(i),month(i),day(i)
                      write (*,*) j,k,count
                      write (*,*) hum(i,j-1),hum(ii,k+1)
                      uhum = hum(ii,k+1)
                      do k=1,count
                         if (j+k-1.le.24) then
                            thum(j+k-1) = (1.*hum(i,j-1)*k + 
     >                           1.*uhum*(count-k))/(1.*count)
                            hum(i,j+k-1) = thum(j+k-1)
                         elseif (j+k-1.le.48) then
                            store(j+k-1-24) = (1.*hum(i,j-1)*k + 
     >                        1.*uhum*(count-k))/(1.*count)
                            hum(i+1,j+k-1-24) = -999
                         else
                            write (*,*) 'over two days'
                            stop
                         endif
                      enddo
                   endif
                elseif (j.eq.1) then
                   if(hum(i-1,24).ne.-99999.and.hum(i,2).ne.-99999)then
                      thum(j) = 0.5*(hum(i-1,24)+hum(i,2))
                   else
                      write (*,*) year(i),month(i),day(i)
                      write (*,*)
     >                     'Need to do more than one value at day start'
                      stop
                   endif
                else
                   if(hum(i,23).ne.-99999.and.hum(i+1,1).ne.-99999)then
                      thum(j) = 0.5*(hum(i,23)+hum(i+1,1))
                   else
                      write (*,*) year(i),month(i),day(i)
                      write (*,*) 
     >                     'Need to do more than one value at day end'
                      stop
                   endif
                endif
             elseif (hum(i,j).eq.-999) then
                hum(i,j) = store(j)
                thum(j) = store(j)
             else
                thum(j) = hum(i,j)
             endif
          enddo

          write (13,0101) stnno, year(i), month(i), day(i), data, 
     >         (thum(j),j=1,24)
        enddo
        if (idatatype.lt.3) then
c     we are using Kate's humidity or air temperature data and we need to shift it by 8 hours
           i = toapril2
           do k=fromapril3,nolines2-1
              i = i + 1
              iyear = cyear(k)
              imonth = cmonth(k)
              iday = cday(k)
              do m=1,16
                 thum(m) = chum(k,m+8)
              enddo
              do m=17,24
                 thum(m) = chum(k+1,m-16)
              enddo
              
              write (13,0101) stnno,iyear,imonth,iday,data,
     >             (thum(m),m=1,24)
           enddo
        endif

 0101   format (2x,i7,1x,i4,1x,i2,1x,i2,1x,i3,24(1x,f6.1))
        close(13)
        
      enddo

      stop
 1001 flag = 1
      goto 1002
      
      end
