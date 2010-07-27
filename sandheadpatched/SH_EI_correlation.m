%quick correlation check - a year of SH and EI data
%-9999s are simply flattened to 0,
%vectors not yet rotated to align with SoG

addpath /ocean/mwolfe/RI/matlab/
addpath /ocean/jsklad/matlab/
addpath /ocean/jsklad/Sandhead/

sD = datenum('January 1, 1996 1:00:00 am');
eD = datenum('December 30, 1997 12:00:00 pm');
SHrange = splicefiles_form('/ocean/jsklad/Sandhead/SH/', 'SH', sD, eD);
EIrange = splicefiles_form('/ocean/jsklad/Sandhead/EI/', 'EI', sD, eD);

SHspd = SHrange(:,6);
SHdir = SHrange(:,5);
EIspd = EIrange(:,6);
EIdir = EIrange(:,5);
SHdate = datenum([ SHrange(:,1) , SHrange(:,2) , SHrange(:,3) , SHrange(:,4) , zeros(length(SHrange(:,1)),1) zeros(length(SHrange(:,1)),1) ]);
EIdate = datenum([ EIrange(:,1) , EIrange(:,2) , EIrange(:,3) , EIrange(:,4) , zeros(length(EIrange(:,1)),1) zeros(length(EIrange(:,1)),1) ]);
EIdir = 10.*EIdir;
SHdir = 10.*SHdir;

%eliminate outliers
for i = 1:length(SHspd)
        if abs(SHspd(i)) > 100
            SHspd(i) = 0;
        end
    end
for i = 1:length(EIspd)
        if abs(EIspd(i)) > 100
            EIspd(i) = 0;
        end
end

for i = 1:length(SHdir)
        if abs(SHdir(i)) > 1000
            SHdir(i) = 0;
        end
end
for i = 1:length(EIdir)
        if abs(EIdir(i)) > 1000
            EIdir(i) = 0;
        end
end

%separate out components of wind (adapted from Susan Allen's code)
SHu = SHspd.*sin(SHdir*(pi/180));
SHv = SHspd.*cos(SHdir*(pi/180));
EIu = EIspd.*sin(EIdir*(pi/180));
EIv = EIspd.*cos(EIdir*(pi/180));

%{
% rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
theta = -55*pi/180.;
EIur = EIu*cos(theta)-EIv*sin(theta);
EIvr = EIu*sin(theta)+EIv*cos(theta);
SHur = SHu*cos(theta)-SHv*sin(theta);
SHvr = SHu*sin(theta)+SHv*cos(theta);

% change wind to from direction (adapted from Susan Allen's code)
EIur = -EIur;
EIvr = -EIvr;
SHur = -SHur;
SHvr = -SHvr;

% where vr is now along the Strait toward 305 degrees and ur is across the Strait toward 35 degrees.
%}

for i = 1:length(SHdir)
        if (SHdir(i) > 35 && SHdir(i) <=215)
            SHdirB(i) = 0;
        else
            SHdirB(i) = 1;
        end
end
for i = 1:length(EIdir)
        if (EIdir(i) > 35 && EIdir(i) <= 215)
            EIdirB(i) = 0.1;
        else
            EIdirB(i) = 1.1;
        end
end

SHspdc = SHspd.^3; %windspeed cubed
EIspdc = EIspd.^3;
    
% figure(1)
% clf
% subplot(2,1,1)
% plot(SHdate(1:500), SHspdc(1:500));
% axdate;
% hold
% plot(EIdate(1:500), EIspdc(1:500), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(1:500), SHdirB(1:500));
% axdate;
% hold
% plot(EIdate(1:500), EIdirB(1:500), 'r');
% axdate;
% 
% figure(2)
% clf
% subplot(2,1,1)
% plot(SHdate(500:1000), SHspdc(500:1000));
% axdate;
% hold
% plot(EIdate(500:1000), EIspdc(500:1000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(500:1000), SHdirB(500:1000));
% axdate;
% hold
% plot(EIdate(500:1000), EIdirB(500:1000), 'r');
% axdate;
% 
% figure(3)
% clf
% subplot(2,1,1)
% plot(SHdate(1500:2000), SHspdc(1500:2000));
% axdate;
% hold
% plot(EIdate(1500:2000), EIspdc(1500:2000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(1500:2000), SHdirB(1500:2000));
% axdate;
% hold
% plot(EIdate(1500:2000), EIdirB(1500:2000), 'r');
% axdate;
% 
% figure(4)
% clf
% subplot(2,1,1)
% plot(SHdate(2000:2500), SHspdc(2000:2500));
% axdate;
% hold
% plot(EIdate(2000:2500), EIspdc(2000:2500), 'r');%{
% axdate;
% subplot(2,1,2)
% plot(SHdate(2000:2500), SHdirB(2000:2500));
% axdate;
% hold
% plot(EIdate(2000:2500), EIdirB(2000:2500), 'r');
% axdate;
% 
% figure(5)
% clf
% subplot(2,1,1)
% plot(SHdate(2500:3000), SHspdc(2500:3000));
% axdate;
% hold
% plot(EIdate(2500:3000), EIspdc(2500:3000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(2500:3000), SHdirB(2500:3000));
% axdate;
% hold
% plot(EIdate(2500:3000), EIdirB(2500:3000), 'r');
% axdate;
% 
% figure(6)
% clf
% subplot(2,1,1)
% plot(SHdate(7000:7500), SHspdc(7000:7500));
% axdate;
% hold
% plot(EIdate(7000:7500), EIspdc(7000:7500), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(7000:7500), SHdirB(7000:7500));
% axdate;
% hold
% plot(EIdate(7000:7500), EIdirB(7000:7500), 'r');
% axdate;
% 
% figure(7)
% clf
% subplot(2,1,1)
% plot(SHdate(7500:8000), SHspdc(7500:8000));
% axdate;
% hold
% plot(EIdate(7500:8000), EIspdc(7500:8000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(7500:8000), SHdirB(7500:8000));
% axdate;
% hold
% plot(EIdate(7500:8000), EIdirB(7500:8000), 'r');
% axdate;

SL = polyfit(SHspd, EIspd, 1);

figure(8)
clf
plot(SHspd, EIspd, '*')
hold
plot(SHspd, SL(1).*SHspd + SL(2), 'g')

SHdirR = SHdir(1:length(SHdir))+10*rand(length(SHdir), 1);
EIdirR = EIdir(1:length(EIdir))+10*rand(length(EIdir), 1);

SD = polyfit(SHdir, EIdir, 1);
figure(9)
clf
plot(SHdirR, EIdirR, '.')
hold
plot(SHdir, SD(1).*SHdir + SD(2), 'g')

figure(10)
clf
plot(SHdir, EIdir, '.')
hold
plot(SHdir, SD(1).*SHdir + SD(2), 'g')

uL = polyfit(EIu, SHu, 1)
uP = polyfit(EIu, SHu, 2);
uC = polyfit(EIu, SHu, 3);
uBC = fminsearch(@func, uL, [ ], EIu, SHu) %combination linear, sqrt

SHuL = uL(1).*EIu+uL(2);
SHuP = uP(1).*EIu.^2 + uP(2).*EIu + uP(3);
SHuC = uC(1).*EIu.^3 + uC(2).*EIu.^2 + uC(3).*EIu + uC(4);
SHuBC = uBC(1).*EIu+uBC(2);

figure(11)
clf
plot(EIu, SHu, '.')
hold
plot(EIu, SHuL, 'g.')
plot(EIu, SHuP, 'm.')
plot(EIu, SHuC, 'y.')
plot(EIu, SHuBC, 'c.')
rUL = sqrt( sum( (SHu(:)-SHuL(:)).^2 ) /numel(SHu));
rUP = sqrt( sum( (SHu(:)-SHuP(:)).^2 ) /numel(SHu));
rUC = sqrt( sum( (SHu(:)-SHuC(:)).^2 ) /numel(SHu));

vL = polyfit(EIv, SHv, 1)
vP = polyfit(EIv, SHv, 2);
vC = polyfit(EIv, SHv, 3);
vBC = fminsearch(@func, vL, [ ], EIv, SHv) %combination linear, sqrt

SHvL = vL(1).*EIv+vL(2);
SHvP = vP(1).*EIv.^2 + vP(2).*EIv + vP(3);
SHvC = vC(1).*EIv.^3 + vC(2).*EIv.^2 + vC(3).*EIv + vC(4);
SHvBC = vBC(1).*EIv+vBC(2);

figure(12)
clf
plot(EIv, SHv, '.')
hold
plot(EIv, SHvL, 'g.')
plot(EIv, SHvP, 'm.')
plot(EIv, SHvC, 'y.')
plot(EIv, SHvBC, 'c.')
rVL = sqrt( sum( (SHv(:)-SHvL(:)).^2 ) /numel(SHv));
rVP = sqrt( sum( (SHv(:)-SHvP(:)).^2 ) /numel(SHv));
rVC = sqrt( sum( (SHv(:)-SHvC(:)).^2 ) /numel(SHv));

rU = [rUL, rUP, rUC]
rV = [rVL, rVP, rVC]