clear i iStart iEnd dateSHm mDate mDateEnd mDateStart nWind row startD xWind yWind
clear all
addpath /ocean/mwolfe/RI/matlab

% Sandheads wind data
load /ocean/jsklad/Sandhead/SH_total.dat
%SH_total = SH_patched_total;

dateSH = datenum( SH_total(:,3) , SH_total(:,2) , SH_total(:,1) , SH_total(:,4) , 0 , 0 ); 
uWind = SH_total(:,5);
vWind = SH_total(:,6);
nWind = atan2(uWind,vWind);
mDate = [ ] ;
mDatesTotal = [ ] ;
miStart = 0;
miEnd = 0;
problem = [];
 
%add this in to make it more adaptable if I'm going to make it a function
sens = 3.5; %Sensitivity; maximum change within a 'suspicious' (extrapolated or missing) section
            %related to slope
gap = 12;   %Minimum gap or extrapolation considered significant, in hours. Shorter gaps/extrapolations are ignored
gapdays = gap/24;   %convert gap to appropriate scale for datenum values

    % set date range for figure 1
    startD = datenum('May 1, 1967 1:00:00 AM');
    endD = datenum('May 10, 2003 11:00:00 PM');
       
        iStart = find(dateSH == startD);
        iEnd = find(dateSH == endD);
        dateSHm = dateSH(iStart:iEnd);
        
        range = 286000:288900;

%find gaps and extrapolations
    flag = false; %flags sections that may be extrapolated or 0s
    row = 0; 

    for i = 2:length(dateSH)-2 %iStart:iEnd  %for full dataset will be 1:length(dateSH)
        prevdiffu = uWind(i) - uWind(i - 1);
        prevdiffv = vWind(i) - vWind(i - 1);
        
        nextdiffu = uWind(i + 1) - uWind(i);
        nextdiffv = vWind(i + 1) - vWind(i);
        
            if flag == false %if we're not yet inside a 'suspicious' section
                if (abs( nextdiffu ) < sens) && (abs(nextdiffv) < sens) 
                    flag = true;
                    mDateStart = dateSH(i + 1);
                    miStart = i;
                end
            elseif flag == true 
                if (~(abs(nextdiffu - prevdiffu) <= 0.00001) | ((uWind(i + 1) > uWind(i)) ~= (uWind(miStart + 1) > uWind(miStart)))) && (~(abs(nextdiffv - prevdiffv) <= 0.00001) | ((vWind(i + 1) > vWind(i)) ~= (vWind(miStart + 1) > vWind(miStart)))) | (abs( nextdiffu ) >= sens) | (i == iEnd) %ie if we're no longer in a section of interpolation
                      
                        flag = false; %to mark the end of the gap/interp section
                        mDateEnd = dateSH(i - 1);
                        miEnd = i;
                    
                        if (mDateEnd - mDateStart >= gapdays)
                            row = row + 1;
                            mDate(row,1) = mDateStart;
                            mDate(row,3) = mDateEnd;
                            mDate(row,4) = miStart;
                            mDate(row,5) = miEnd;
                        end
                end
            end      
    end

mDatesTotal = [ mDatesTotal ; mDate ];
figure(1); clf; plot(range, SH_total(range, 5));
    
  

