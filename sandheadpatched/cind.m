%function to convert individual wspd and direction
%choose YVR or EI correlation

function[SHuNew1, SHvNew1] = cind(wdirEC, wspdEC, tag)
   
    
        wdirEC = wdirEC .* 10;
        wspdEC = wspdEC .* 1000 .* (1/3600); % from km/h to m/s

        %separate out components of wind (adapted from Susan Allen's code)
        wECu = wspdEC.*sin(wdirEC*(pi/180));
        wECv = wspdEC.*cos(wdirEC*(pi/180));

if tag == 'EI'   %using EI correlation
     
     uL = [0.6837, 0.4776]; 
     vL = [0.6668, -0.0123];
   
elseif tag == 'YV' | tag == 'YVR' %using YVR correlation
    uL = [1.1060, 0.5657]; 
    vL = [1.2744, 0.0383];
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
        SHuNew1 = -wECur;
        SHvNew1 = -wECvr;
        % where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.
