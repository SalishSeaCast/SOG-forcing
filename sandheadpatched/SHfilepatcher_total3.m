% file to patch some of the holes in SH_total data with EI data
% namely, the holes from August 19th, 1999 and on

clear all

addpath /ocean/jsklad/matlab
addpath /ocean/jsklad/Sandhead
addpath /ocean/mwolfe/RI/matlab

load /ocean/sallen/allen/research/sog/sog-forcing/wind/SH_total.dat %Historic SH data
dateSH = datenum( SH_total(:,3) , SH_total(:,2) , SH_total(:,1) , SH_total(:,4) , 0 , 0 ); 

%error = [];

%data from historic SH set
    uSH = SH_total(:,5);
    vSH = SH_total(:,6);
    spSH = sqrt(uSH.^2 + vSH.^2);

    %wind direction in relation to alignment of Straight
    drSH = atan2(uSH,vSH);

    U = load('/ocean/jsklad/Sandhead/mDatesTotalpm12.mat');
    smDates = U.mDatesTotal(:,1); %start of missing chunk
    emDates = U.mDatesTotal(:,3); %end of missing chunk
   
iFirst = find(dateSH == smDates(1));

SHdatesTotal = [dateSH(1:iFirst)];
SHuNewTotal = [uSH(1:iFirst)];
SHvNewTotal = [vSH(1:iFirst)];

for i = 1:length(smDates)
% for a range of dates:
    sDate = smDates(i);
    eDate = emDates(i);
    
    iStart = find(dateSH == sDate);
        if i<length(smDates)
        iStartNext = find(dateSH == smDates(i+1)); %for filling the space after the gap with SH historic data
        else 
            iStartNext = find(dateSH, 1, 'last');
        end   
    iEnd = find(dateSH == eDate);

    vecStart = datevec(sDate);
    vecEnd = datevec(eDate);

    %values of year and month to help find correct file(s)
    startY = vecStart(1,1);
    startM = vecStart(1,2);
    endY = vecEnd(1,1);
    endM = vecEnd(1,2);

    numMonths = endM - startM + 12*(endY - startY) + 1; 

    %load the EI files for the gap into a dataset
    %requires loading some individual month files into a single array
        EC = [];
        
        if (sDate < datenum('August 18, 1998')) | ((sDate > datenum('21-Nov-2008 10:00:00')) && (sDate < datenum('01-Dec-2008 20:00:00')))
            location = '/ocean/jsklad/Sandhead/YV/';
            tag = 'YV';
        else
            location = '/ocean/jsklad/Sandhead/EI/';
            tag = 'EI';
        end

        %load files into single matrix curData
        curY = startY;
        curM = startM;
        for k = 1:numMonths
                if curM < 10
                    curFile = sprintf('%s%s_%4i_0%i_form', location, tag, curY, curM);
                else
                    curFile = sprintf('%s%s_%4i_%i_form', location, tag, curY, curM);
                end
            curData = load(curFile);
            EC = [EC; curData];
                if curM < 12
                    curM = curM + 1; 
                else
                    curM = 1;
                    curY = curY + 1;
                end
        end
        
    %get info from EC data
 
        dateEC = datenum([ EC(:,1) , EC(:,2) , EC(:,3) , EC(:,4) , zeros(length(EC(:,1)),1) zeros(length(EC(:,1)),1) ]);
        iSegStart = find(dateEC == sDate);
        iSegEnd = find(dateEC == eDate);
        dateEC = dateEC;
        wdirEC = EC(:,5);
        wdirEC = wdirEC .* 10; % from 10ths of a degree to degrees
        wdirECorig = wdirEC;
        wspdEC = EC(:,6);
        wspdECorig = wspdEC;
  
        
    %interpolate holes (-9999 subbed in for NaNs)~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        holes = find(wdirEC(:) < 0);
        
        if numel(holes) > 0
        
            starting_hole_index = 1;
            end_index_hole=1;   

            start_position = holes(starting_hole_index) - 1;

            for j=1:length(holes)-1
                %if start_position == 0
                    
                if (holes(j + 1) ~= holes(j) + 1) %|| (holes(j+1) == holes(length(holes)))
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;

                    %interpolation
                    yEC = [wdirEC(start_position) wdirEC(end_position)];
                    xEC = [dateEC(start_position) dateEC(end_position)];   
                    x1EC = dateEC(start_position:end_position);


                    wdirEC(start_position:end_position) = interp1(xEC,yEC,x1EC);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                elseif holes(j+1) == holes(length(holes)) 
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;

                    %interpolation
                    yEC = [wdirEC(start_position) wdirEC(end_position)];
                    xEC = [dateEC(start_position) dateEC(end_position)];   
                    x1EC = dateEC(start_position:end_position);

                    wdirEC(start_position:end_position) = interp1(xEC,yEC,x1EC);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                end    
            end
            
            starting_hole = find((wdirEC < 0), 1, 'first');
            end_hole = find((wdirEC < 0), 1, 'last');        
            start_position = starting_hole - 1;

            %interpolation
            if end_hole < length(wdirEC)
                end_position = end_hole + 1;
                yCS = [wdirEC(start_position) wdirEC(end_position)];
                xCS = [dateEC(start_position) dateEC(end_position)];   
                x1CS = dateEC(start_position:end_position);
                wdirEC(start_position:end_position) = interp1(xCS,yCS,x1CS);
            else
                yCS = [wdirEC(start_position) wdirEC(start_position - 7)];
                xCS = [dateEC(start_position) dateEC(start_position - 7)];   
                x1CS = dateEC((start_position - 7):start_position);
                wdirEC(start_position:end_hole) = interp1(xCS,yCS,x1CS);         
            end
        end
      
        %for windspeeds, holes
             
        holes = find(wspdEC < 0);
        
        if numel(holes) >0
        
            starting_hole_index = 1;
            end_index_hole=1;   
            start_position = holes(starting_hole_index) - 1;

            for j=1:length(holes)-1
                if (holes(j + 1) ~= holes(j) + 1)
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;

                    %interpolation
                    yEC = [wspdEC(start_position) wspdEC(end_position)];
                    xEC = [dateEC(start_position) dateEC(end_position)];   
                    x1EC = dateEC(start_position:end_position);

                    wspdEC(start_position:end_position) = interp1(xEC,yEC,x1EC);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                elseif holes(j+1) == holes(length(holes)) 
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;

                    %interpolation
                    yEC = [wspdEC(start_position) wspdEC(end_position)]; %here's the change
                    xEC = [dateEC(start_position) dateEC(end_position)];   
                    x1EC = dateEC(start_position:end_position);


                    wdirEC(start_position:end_position) = interp1(xEC,yEC,x1EC);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;

                end    
            end

            starting_hole = find((wspdEC < 0), 1, 'first');
            end_hole = find((wspdEC < 0), 1, 'last');        
            start_position = starting_hole - 1;

            %interpolation
            if end_hole < length(wspdEC)
                end_position = end_hole + 1;
                yCS = [wspdEC(start_position) wspdEC(end_position)];
                xCS = [dateEC(start_position) dateEC(end_position)];   
                x1CS = dateEC(start_position:end_position);
                wspdEC(start_position:end_position) = interp1(xCS,yCS,x1CS);
            else
                yCS = [wspdEC(start_position) wspdEC(start_position - 7)];
                xCS = [dateEC(start_position) dateEC(start_position - 7)];   
                x1CS = dateEC((start_position - 7):start_position);
                wspdEC(start_position:end_hole) = interp1(xCS,yCS,x1CS);         
            end
        end

        dateEC = dateEC(iSegStart:iSegEnd);
        wdirEC = wdirEC(iSegStart:iSegEnd);
        wspdEC = wspdEC(iSegStart:iSegEnd);
        
        wspdEC = wspdEC .* 1000 .* (1/3600); % from km/h to m/s

        %separate out components of wind (adapted from Susan Allen's code)
        wECu = wspdEC.*sin(wdirEC*(pi/180));
        wECv = wspdEC.*cos(wdirEC*(pi/180));
        
    %Correction factor for converting EI to SH wind
        % Slope and intersect values for linear correlation between EI and
        % SH (see SH_EI_correlation.m, SH_YV_correlation.m)
        if sDate < datenum('August 18, 1998') %use YVR correlation
            uL = [1.1060, 0.5657]; 
            vL = [1.2744, 0.0383];
        else
            uL = [0.6837, 0.4776]; 
            vL = [0.6668, -0.0123];
        end
              
        %wECuN = bestcoeffU(1).*
        wECuN = uL(1).*wECu + uL(2).*abs(wECu.^0.5);
        wECvN = vL(1).*wECv + vL(2).*abs(wECu.^0.5);
        
     %Adapt data to be aligned with the Straight       
        % rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
        theta = -55*pi/180.;
        wECur = wECuN*cos(theta)-wECvN*sin(theta);
        wECvr = wECuN*sin(theta)+wECvN*cos(theta);

        % change wind to from direction (adapted from Susan Allen's code)
        SHuNew = -wECur;
        SHvNew = -wECvr;
        % where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.
     
        SHdatesTotal = [SHdatesTotal; dateSH(iStart:iEnd); dateSH(iEnd+1:iStartNext-1)];
        SHuNewTotal = [SHuNewTotal; SHuNew; uSH(iEnd+1:iStartNext-1)];
        SHvNewTotal = [SHvNewTotal; SHvNew; vSH(iEnd+1:iStartNext-1)];
        

   
end

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%add missing dates from 2006-2010 to end, directly from Environment Canada
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


startD = datenum('April 1, 2006');
endD = datenum('May 20, 2010');
location = '/ocean/jsklad/Sandhead/SH/';
tag = 'SH';
lData = splicefiles_form(location, tag, startD, endD); %function loads individual month files into single array
lDates = datenum( lData(:,1) , lData(:,2) , lData(:,3) , lData(:,4) , 0 , 0 );


firstEndDate = SHdatesTotal(length(SHdatesTotal));
lStartIndex = find(lDates == firstEndDate) + 1;
lDataTrimmed = lData(lStartIndex:end,:);
dateL = datenum( lDataTrimmed(:,1) , lDataTrimmed(:,2) , lDataTrimmed(:,3) , lDataTrimmed(:,4) , 0 , 0 );
wspdL = lDataTrimmed(:,6);
wdirL = lDataTrimmed(:,5);
wdirL = wdirL.*10; %from tenths of a degree to degrees


    %interpolate holes~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        holes = find(wdirL < 0);
        
        if numel(holes) >0
        
            starting_hole_index = 1;
            end_index_hole=1;   

            start_position = holes(starting_hole_index) - 1;

            for j=1:length(holes)-1
                if (holes(j + 1) ~= holes(j) + 1) %|| (holes(j+1) == holes(length(holes)))
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;
                    
                    %interpolation
                    yL = [wdirL(start_position) wdirL(end_position)];
                    xL = [dateL(start_position) dateL(end_position)];   
                    x1L = dateL(start_position:end_position);

                    wdirL(start_position:end_position) = interp1(xL,yL,x1L);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                elseif holes(j+1) == holes(length(holes)) 
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;
                    
                    %interpolation
                    yL = [wdirL(start_position) wdirL(end_position)];
                    xL = [dateL(start_position) dateL(end_position)];   
                    x1L = dateL(start_position:end_position);

                    wdirL(start_position:end_position) = interp1(xL,yL,x1L);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                end    
            end
            
            starting_hole = find((wdirL < 0), 1, 'first');
            end_hole = find((wdirL < 0), 1, 'last');        
            start_position = starting_hole - 1;

            if end_hole < length(wdirL)
                end_position = end_hole + 1;
                yL = [wdirL(start_position) wdirL(end_position)];
                xL = [dateL(start_position) dateL(end_position)];   
                x1L = dateL(start_position:end_position);
                wdirL(start_position:end_position) = interp1(xL,yL,x1L);
            else
                wdirL(start_position:end_hole) = 0;
            end
        end
        %for windspeeds, holes
 
        holes = find(wspdL < 0);
        
        if numel(holes) >0
        
            starting_hole_index = 1;
            end_index_hole=1;   
            start_position = holes(starting_hole_index) - 1;

            for j=1:length(holes)-1
                if (holes(j + 1) ~= holes(j) + 1) %|| (holes(j+1) == holes(length(holes)))
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;
                    
                    %interpolation
                    yL = [wspdL(start_position) wspdL(end_position)];
                    xL = [dateL(start_position) dateL(end_position)];   
                    x1L = dateL(start_position:end_position);

                    wspdL(start_position:end_position) = interp1(xL,yL,x1L);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                elseif holes(j+1) == holes(length(holes)) 
                    end_index_hole = j;
                    end_position = holes(end_index_hole) + 1;
                    
                    %interpolation
                    yL = [wspdL(start_position) wspdL(end_position)];
                    xL = [dateL(start_position) dateL(end_position)];   
                    x1L = dateL(start_position:end_position);

                    wdirL(start_position:end_position) = interp1(xL,yL,x1L);

                    starting_hole_index = j+1;
                    start_position = holes(starting_hole_index) - 1;
                end    
            end

            starting_hole = find((wspdL < 0), 1, 'first');
            end_hole = find((wspdL < 0), 1, 'last');        
            start_position = starting_hole - 1;

            if end_hole < length(wspdL)
                end_position = end_hole + 1;
                yL = [wspdL(start_position) wspdL(end_position)];
                xL = [dateL(start_position) dateL(end_position)];   
                x1L = dateL(start_position:end_position);
                wspdL(start_position:end_position) = interp1(xL,yL,x1L);
            else
                wspdL(start_position:end_hole) = 0;
            end
        end

        wspdL = wspdL .* 1000 .* (1/3600); % from km/h to m/s

        %separate out components of wind (adapted from Susan Allen's code)
        wLu = wspdL.*sin(wdirL*(pi/180));
        wLv = wspdL.*cos(wdirL*(pi/180));
        
       
     %Adapt data to be aligned with the Straight       
        % rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
        theta = -55*pi/180.;
        wLur = wLu*cos(theta)-wLv*sin(theta);
        wLvr = wLu*sin(theta)+wLv*cos(theta);

        % change wind to from direction (adapted from Susan Allen's code)
        wLur = -wLur;
        wLvr = -wLvr;
        % where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.
     

SHdatesTotal = [SHdatesTotal; dateL];
SHuNewTotal = [SHuNewTotal; wLur];
SHvNewTotal = [SHvNewTotal; wLvr];

%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~plot figures and generate file~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

SHdatesvec = datevec(SHdatesTotal);
Ny = SHdatesvec(:,1);
Nm = SHdatesvec(:,2);
Nd = SHdatesvec(:,3);
Nh = SHdatesvec(:,4);
Nmn = zeros(length(SHdatesvec(:,1)),1);
Nsc = zeros(length(SHdatesvec(:,1)),1);


for i = 1:length(smDates), range = U.mDatesTotal(i,4)-30:U.mDatesTotal(i,5)+30; 
    figure(i); clf; 
    subplot(2,1,1), plot(SHdatesTotal(range), SHuNewTotal(range), 'r'); 
    hold on;
    plot(dateSH(range),uSH(range))
    legend('Patched data', 'Original data')
    xlabel('Date')
    ylabel('Velocity U (m/s across Straight)')
    subplot(2,1,2), plot(SHdatesTotal(range), SHvNewTotal(range), 'r'); 
    hold on;
    plot(dateSH(range),vSH(range))
    legend('Patched data', 'Original data')
    xlabel('Date')
    ylabel('Velocity U (m/s across Straight)')
end

%write a file with all the patched data
N_SH = [Nd Nm Ny Nh SHuNewTotal SHvNewTotal];
% newFile = strcat('/ocean/jsklad/Sandhead/SH_patched_Jul27_2010.dat')
% dlmwrite(newFile, N_SH, '\t');


    

      
        
    
        
