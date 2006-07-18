% CompositeWind

clear all;

% read in the two base wind files (recent sandheads file and Kate's
% original wind file) : Note that Kate's 2001 data until Sep is just a repeat of 2002 -- this will be fixed later by already rotated wind
 % and sandheads file has Entrance Island wind for a section and this needs to be fixed too .. 
% read corrected Sandheads (WVF) from sandhead_apr2006-jul2005.mat first and insert it just before rotating

%data in "sand", move it to Sand05
load sandhead_apr2005-jul2005.mat
Sand05 = sand;
% calculate the u,v components of the wind shere u is wind from the east and v is wind from the north -- weird conversion because direction is a clockwise measure starting from north!
% this conversion is identical to that in /ocean/rich/home/rescan/wen2/spdir2uv.m
 Sand05.u = Sand05.wspeed.*sin(Sand05.wdir*(pi/180));
 Sand05.v = Sand05.wspeed.*cos(Sand05.wdir*(pi/180));
clear sand;

% data in "sand"
%load /ocean/shared/SoG/met_data/sand_sept2001-apr2006.mat
load sand_sept2001-apr2006.mat
% index at which mtime=732200
isandmin = 26341;
% maximum index in sand
isandmax = 40205;
% data in "wind"
%load /ocean/kcollins/sog/input/wind/wind.mat
load wind.mat
% index at which mtime=732200
iwindmax = 32361;


% set up array

imax = iwindmax+isandmax-isandmin
windsand.mtime = zeros(imax,1);
windsand.u = zeros(imax,1);
windsand.v = zeros(imax,1);

% first part of array comes from Wind as it is filled and despiked
windsand.mtime(1:iwindmax) = wind.mtime(1:iwindmax);
windsand.u(1:iwindmax) = wind.u(1:iwindmax);
windsand.v(1:iwindmax) = wind.v(1:iwindmax);

% second part of array comes from Sand as Wind is incorrect (Oct 2004-
% Apr 2005 section is yvr wind) and short
windsand.mtime(iwindmax+1:imax) = sand.mtime(isandmin+1:isandmax);
windsand.u(iwindmax+1:imax) = sand.u(isandmin+1:isandmax);
windsand.v(iwindmax+1:imax) = sand.v(isandmin+1:isandmax);

% now a section of this needs to be substituted from Sand05
isand05 = 37341;
% index in windsand that corresponds to first Sand05 data point
isand05e = 39514;
% index in windsand that corresponds to last Sand05 data point
sSand05 = 2639;
% total number of entries in Sand05, note that 39514-37341+1 = 2174 (big difference is much repeated data in Sand05 file)
tmax = imax+sSand05-isand05e+isand05-1
windsand.mtime(isand05+sSand05:tmax) = windsand.mtime(isand05e+1:imax);
windsand.u(isand05+sSand05:tmax) = windsand.u(isand05e+1:imax);
windsand.v(isand05+sSand05:tmax) = windsand.v(isand05e+1:imax);

windsand.mtime(isand05:isand05+sSand05-1) = Sand05.mtime(1:sSand05);
windsand.u(isand05:isand05+sSand05-1) = Sand05.u(1:sSand05);
windsand.v(isand05:isand05+sSand05-1) = Sand05.v(1:sSand05);

imax = tmax;

% note that wind is in wind from direction, ie +u is from the east, +v is
% from the north

% rotate wind 55 degrees clockwise
theta = -55*pi/180.
windsand.ux = windsand.u*cos(theta)-windsand.v*sin(theta);
windsand.va = windsand.u*sin(theta)+windsand.v*cos(theta);

% change wind to from direction
windsand.ux = -windsand.ux;
windsand.va = -windsand.va;

% where va is now along the Strait toward 305 degrees and ux is across the Strait toward 35 degrees.

% now need to replace the early 2001 data
sep01 = datenum([2001 09 01 0 0 0]);
sep01i = (245-2)*24+1;
if (windsand.mtime(sep01i) ~= sep01) stop; end
% yes I know stop doesn't work but the problem is a mismatch between indicies.. if this doesn't equal zero you need to fix it

load SH.str
Shindex0 = 295168;
Shindex= 301000-1;
% Roy using longshore then cross-shore
windsand.ux(1:sep01i-1) = SH(Shindex0:Shindex,9);
windsand.va(1:sep01i-1) = SH(Shindex0:Shindex,8);


% plot time series inconsistencies
dt = windsand.mtime(2)-windsand.mtime(1);
at0(1:imax-1) = windsand.mtime(2:imax)-windsand.mtime(1:imax-1)-dt;

% fix data time series removing repeated times and linearly interpolating over holes - Note missing data in Roys is -99  -- note only holes upto 3 hours are handled... beyond that code will "stop"
small=1e-9;
prevtime = windsand.mtime(1);
done = 0;
i=2;
while done==0
   at = windsand.mtime(i)-prevtime;
   if abs(at-dt) > small | windsand.ux(i) == -99
       if at==0 
          if windsand.u(i-1)*windsand.v(i-1) == 0 
% remove the previous one
             'remove'
             [imax-1 i]
% close gap
             for j=i:imax
                windsand.u(j-1) = windsand.u(j);
                windsand.v(j-1) = windsand.v(j);
                windsand.mtime(j-1) = windsand.mtime(j);
                windsand.ux(j-1) = windsand.ux(j);
                windsand.va(j-1) = windsand.va(j);
             end
             imax = imax-1;
          else
% remove the second one
             'remove' 
             [imax-1 i]
% close gap
             for j=i+1:imax
                windsand.u(j-1) = windsand.u(j);
                windsand.v(j-1) = windsand.v(j);
                windsand.mtime(j-1) = windsand.mtime(j);
                windsand.ux(j-1) = windsand.ux(j);
                windsand.va(j-1) = windsand.va(j);
             end
             imax = imax-1;
          end
        elseif at<0
% remove the second one
             'remove'
             [imax-1 i]
% close gap
             for j=i+1:imax
                windsand.u(j-1) = windsand.u(j);
                windsand.v(j-1) = windsand.v(j);
                windsand.mtime(j-1) = windsand.mtime(j);
                windsand.ux(j-1) = windsand.ux(j);
                windsand.va(j-1) = windsand.va(j);
             end
             imax = imax-1; 
	elseif abs(at-0.0417) <0.01 & windsand.ux(i) ~= -99
% leave and hope for the best
           prevtime=windsand.mtime(i);
           i = i +1;
           if (i == imax) 
              done = 1
           end

	elseif abs(at-0.0417*2) < 0.01 | (windsand.ux(i) == -99 & windsand.ux(i+1) ~= -99)
	      if abs(at-0.0417*2) < 0.01
% move everything down by one
                'fill'
                [imax+1 i]
                for j=imax:-1:i
                   windsand.u(j+1) = windsand.u(j);
                   windsand.v(j+1) = windsand.v(j);
                   windsand.mtime(j+1) = windsand.mtime(j);
                   windsand.ux(j+1) = windsand.ux(j);
                   windsand.va(j+1) = windsand.va(j);
                end
                imax = imax+1; 
             end
% and fill
             windsand.u(i) = (windsand.u(i+1)+windsand.u(i-1))/2;
             windsand.v(i) = (windsand.v(i+1)+windsand.v(i-1))/2;
             windsand.mtime(i) = (windsand.mtime(i+1)+windsand.mtime(i-1))/2;
             windsand.ux(i) = (windsand.ux(i+1)+windsand.ux(i-1))/2;
             windsand.va(i) = (windsand.va(i+1)+windsand.va(i-1))/2;
             prevtime=windsand.mtime(i);
             i = i + 1;
	  elseif abs(at-0.0417*3) < 0.01 | (windsand.ux(i) == -99 & windsand.ux(i+1) == -99 & windsand.ux(i+2) ~= -99)
	     if abs(at-0.0417*3) < 0.01
% move everything down by 2
                'fill 2'
                [imax+2 i]
                for j=imax:-1:i
                   windsand.u(j+2) = windsand.u(j);
                   windsand.v(j+2) = windsand.v(j);
                   windsand.mtime(j+2) = windsand.mtime(j);
                   windsand.ux(j+2) = windsand.ux(j);
                   windsand.va(j+2) = windsand.va(j);
                end
                imax = imax+2; 
             end
% and fill
             windsand.u(i+1) = (2*windsand.u(i+2)+windsand.u(i-1))/3;
             windsand.v(i+1) = (2*windsand.v(i+2)+windsand.v(i-1))/3;
             windsand.mtime(i+1) = (2*windsand.mtime(i+2)+windsand.mtime(i-1))/3;
             windsand.ux(i+1) = (2*windsand.ux(i+2)+windsand.ux(i-1))/3;
             windsand.va(i+1) = (2*windsand.va(i+2)+windsand.va(i-1))/3;

             windsand.u(i) = (windsand.u(i+2)+2*windsand.u(i-1))/3;
             windsand.v(i) = (windsand.v(i+2)+2*windsand.v(i-1))/3;
             windsand.mtime(i) = (windsand.mtime(i+2)+2*windsand.mtime(i-1))/3;
             windsand.ux(i) = (windsand.ux(i+2)+2*windsand.ux(i-1))/3;
             windsand.va(i) = (windsand.va(i+2)+2*windsand.va(i-1))/3;
             prevtime=windsand.mtime(i);
	     i = i + 1;

        elseif abs(at-0.0417*4) < 0.01 | (windsand.ux(i) == -99 & windsand.ux(i+1) == -99 & windsand.ux(i+2) == -99 & windsand.ux(i+3) ~= -99)
	     if abs(at-0.0417*4) < 0.01
% move everything down by 3
                'fill 3'
                [imax+3 i]
                for j=imax:-1:i
                   windsand.u(j+3) = windsand.u(j);
                   windsand.v(j+3) = windsand.v(j);
                   windsand.mtime(j+3) = windsand.mtime(j);
                   windsand.ux(j+3) = windsand.ux(j);
                   windsand.va(j+3) = windsand.va(j);
                end
                imax = imax+3; 
             end
% and fill
             windsand.u(i+2) = (3*windsand.u(i+3)+windsand.u(i-1))/4;
             windsand.v(i+2) = (3*windsand.v(i+3)+windsand.v(i-1))/4;
             windsand.mtime(i+2) = (3*windsand.mtime(i+3)+windsand.mtime(i-1))/4;
             windsand.ux(i+2) = (3*windsand.ux(i+3)+windsand.ux(i-1))/4;
             windsand.va(i+2) = (3*windsand.va(i+3)+windsand.va(i-1))/4;

             windsand.u(i+1) = (windsand.u(i+3)+windsand.u(i-1))/2;
             windsand.v(i+1) = (windsand.v(i+3)+windsand.v(i-1))/2;
             windsand.mtime(i+1) = (windsand.mtime(i+3)+windsand.mtime(i-1))/2;
             windsand.ux(i+1) = (windsand.ux(i+3)+windsand.ux(i-1))/2;
             windsand.va(i+1) = (windsand.va(i+3)+windsand.va(i-1))/2;

             windsand.u(i) = (windsand.u(i+3)+3*windsand.u(i-1))/4;
             windsand.v(i) = (windsand.v(i+3)+3*windsand.v(i-1))/4;
             windsand.mtime(i) = (windsand.mtime(i+3)+3*windsand.mtime(i-1))/4;
             windsand.ux(i) = (windsand.ux(i+3)+3*windsand.ux(i-1))/4;
             windsand.va(i) = (windsand.va(i+3)+3*windsand.va(i-1))/4;

             prevtime=windsand.mtime(i);
             i = i + 1;
         else
           windsand.mtime(i)
           datevec(windsand.mtime(i))
           datevec(windsand.mtime(i-1))
           stop
        end
     else
        prevtime=windsand.mtime(i);
        i = i +1;
        if (i == imax) 
           done = 1
        end
     end
end

% change time from UTC to PST (or Local Standard Time)

windsand.mtime = windsand.mtime - datenum([0 0 0 8 0 0]);

% remove first s8 records so that we start Jan 1, 2001 

% need to write shortened arrays
SandWind.mtime = windsand.mtime(9:imax);
SandWind.ux = windsand.ux(9:imax);
SandWind.va = windsand.va(9:imax);

SandWind.comments = 'Winds is in m/s, .ux is across Strait TO 35 degrees, .va is along Strait TO 305 degrees. Wind is from Sand Heads.  Time is in mtime format and is PST'

save ('windsand-jan2001-apr2006.mat','SandWind')

SandRot(:,5) = SandWind.ux;
SandRot(:,6) = SandWind.va;

[year month day hour minute second] = datevec(SandWind.mtime);

for i=1:imax-8
   if (minute(i)>=30) hour(i)=hour(i)+1; end
end

for i=1:imax-8
   if (hour(i)==24) 
     hour(i) = 0;
     if (month(i) == month(i+1)) % we are not at the end of month
      day(i) = day(i)+1;
     elseif (year(i) == year(i+1)) % end of month but not end of year
      day(i) = 1;
      month(i) = month(i) + 1;
     else
      year(i) = year(i) + 1;
      month(i) = 1;
      day(i) = 1;
     end
   end
end

SandRot(:,1) = day;
SandRot(:,2) = month;
SandRot(:,3) = year;
SandRot(:,4) = hour;

save -ascii SHcompRot.dat SandRot

%*************************************
% Create a UTC unrotated version for the shared directory
clear sand

% back to UTC
sand.mtime = windsand.mtime(1:imax) + datenum([0 0 0 8 0 0]);

% wind components
				   sand.ux = windsand.ux(1:imax);
				   sand.va = windsand.va(1:imax);
% change to TO direction
				   ux = -sand.ux;
				   va = -sand.va;
% rotate wind 55 degrees counter-clockwise
				   theta = 55*pi/180.;
				   sand.u = ux*cos(theta)-va*sin(theta);
				   sand.v = ux*sin(theta)+va*cos(theta);

sand.comments = 'Winds is in m/s, .ux is across Strait TO 35 degrees, .va is along Strait TO 305 degrees. u is FROM east. v is FROM north. Wind is from Sand Heads.  Time is in mtime format and is UTC'

				   save ('sand_jan2001-apr2006.mat','sand')

