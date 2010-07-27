clear all
load /ocean/jsklad/Sandhead/SH_patched_Jul20b_2010.dat
SH_patched = SH_patched_Jul20b_2010;

dPatched = datenum( SH_patched(:,3) , SH_patched(:,2) , SH_patched(:,1) , SH_patched(:,4) , 0 , 0 ); 
uPatched = SH_patched(:,5);
vPatched = SH_patched(:,6);

% dPatched2 = datenum( SH_patched(:,3) , SH_patched(:,2) , SH_patched(:,1) , SH_patched(:,4) , 0 , 0 ); 
% uPatched2 = SH_patched(:,5);
% vPatched2 = SH_patched(:,6);

EC = [];
location = '/ocean/jsklad/Sandhead/YV/';
tag = 'YV';

%load files into single matrix curData
numMonths = 2;         
curY = 2008;
curM = 11;
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
SHuNew = [];
SHvNew = [];

    sGap = [364340 364457];
    eGap = [364441 364569];
    
%first gap~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~      
    %get info from EC data
    dateEC = datenum([ EC(:,1) , EC(:,2) , EC(:,3) , EC(:,4) , zeros(length(EC(:,1)),1) zeros(length(EC(:,1)),1) ]);
        
        iSegStart = find(dateEC == dPatched(sGap(1)));
        iSegEnd = find(dateEC == dPatched(eGap(1)));
        %dateEC = dateEC(iSegStart:iSegEnd); %only keep the necessary segment
        %wdirEC = EC(iSegStart:iSegEnd,5);
        wdirEC = EC(:,5);
        wdirEC = wdirEC .* 10; % from 10ths of a degree to degrees
        wdirECorig = wdirEC;
        %wspdEC = EC(iSegStart:iSegEnd,6);
        wspdEC = EC(:,6);
        wspdECorig = wspdEC;

        dateEC = dateEC(iSegStart:iSegEnd);
        wdirEC = wdirEC(iSegStart:iSegEnd);
        wspdEC = wspdEC(iSegStart:iSegEnd);

        wspdEC = wspdEC .* 1000 .* (1/3600); % from km/h to m/s

        %separate out components of wind (adapted from Susan Allen's code)
        wECu = wspdEC.*sin(wdirEC*(pi/180));
        wECv = wspdEC.*cos(wdirEC*(pi/180));

    %using EI correlation
    % uL = [0.6837, 0.4776]; 
    % vL = [0.6668, -0.0123];
    %using YVR correlation
    uL = [1.1060, 0.5657]; 
    vL = [1.2744, 0.0383];

     %wECuN = bestcoeffU(1).*
        wECuN = uL(1).*wECu + uL(2).*abs(wECu.^0.5);
        wECvN = vL(1).*wECv + vL(2).*abs(wECu.^0.5);

     %Adapt data to be aligned with the Straight       
        % rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
        theta = -55*pi/180.;
        wECur = wECuN*cos(theta)-wECvN*sin(theta);
        wECvr = wECuN*sin(theta)+wECvN*cos(theta);

        % change wind to from direction (adapted from Susan Allen's code)
        SHuNew1 = -wECur;
        SHvNew1 = -wECvr;
        % where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.
        
        
%second gap~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~        
        
dateEC = datenum([ EC(:,1) , EC(:,2) , EC(:,3) , EC(:,4) , zeros(length(EC(:,1)),1) zeros(length(EC(:,1)),1) ]);
        iSegStart = find(dateEC == dPatched(sGap(2)));
        iSegEnd = find(dateEC == dPatched(eGap(2)));
        %dateEC = dateEC(iSegStart:iSegEnd); %only keep the necessary segment
        %wdirEC = EC(iSegStart:iSegEnd,5);
        wdirEC = EC(:,5);
        wdirEC = wdirEC .* 10; % from 10ths of a degree to degrees
        wdirECorig = wdirEC;
        %wspdEC = EC(iSegStart:iSegEnd,6);
        wspdEC = EC(:,6);
        wspdECorig = wspdEC;

        dateEC = dateEC(iSegStart:iSegEnd);
        wdirEC = wdirEC(iSegStart:iSegEnd);
        wspdEC = wspdEC(iSegStart:iSegEnd);

        wspdEC = wspdEC .* 1000 .* (1/3600); % from km/h to m/s

        %separate out components of wind (adapted from Susan Allen's code)
        wECu = wspdEC.*sin(wdirEC*(pi/180));
        wECv = wspdEC.*cos(wdirEC*(pi/180));

    %using EI correlation
    % uL = [0.6837, 0.4776]; 
    % vL = [0.6668, -0.0123];
    %using YVR correlation
    uL = [1.1060, 0.5657]; 
    vL = [1.2744, 0.0383];

     %wECuN = bestcoeffU(1).*
        wECuN = uL(1).*wECu + uL(2).*abs(wECu.^0.5);
        wECvN = vL(1).*wECv + vL(2).*abs(wECu.^0.5);

     %Adapt data to be aligned with the Straight       
        % rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
        theta = -55*pi/180.;
        wECur = wECuN*cos(theta)-wECvN*sin(theta);
        wECvr = wECuN*sin(theta)+wECvN*cos(theta);

        % change wind to from direction (adapted from Susan Allen's code)
        SHuNew2 = -wECur;
        SHvNew2 = -wECvr;
        % where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.



% uPatched2 = [uPatched(1:sGap(1)-1); SHuNew1; uPatched(eGap(1)+1:length(uPatched))];
% vPatched2 = [vPatched(1:sGap(1)-1); SHvNew1; vPatched(eGap(1)+1:length(vPatched))];
uPatched2 = [uPatched(1:sGap(1)-1); SHuNew1; uPatched(eGap(1)+1:sGap(2)-1); SHuNew2; uPatched(eGap(2)+1:length(uPatched))];
vPatched2 = [vPatched(1:sGap(1)-1); SHvNew1; vPatched(eGap(1)+1:sGap(2)-1); SHvNew2; vPatched(eGap(2)+1:length(vPatched))];

SHdatesvec = datevec(dPatched);
Ny = SHdatesvec(:,1);
Nm = SHdatesvec(:,2);
Nd = SHdatesvec(:,3);
Nh = SHdatesvec(:,4);
Nmn = zeros(length(SHdatesvec(:,1)),1);
Nsc = zeros(length(SHdatesvec(:,1)),1);
N_SH = [Nd Nm Ny Nh uPatched2 vPatched2];
% newFile = strcat('/ocean/jsklad/Sandhead/SH_patched_Jul22b_2010.dat')
% dlmwrite(newFile, N_SH, '\t');

figure(1); clf; hold on; plot(uPatched2(sGap(1)-20:eGap(2)+20), 'r'); plot(uPatched(sGap(1)-20:eGap(2)+20))


