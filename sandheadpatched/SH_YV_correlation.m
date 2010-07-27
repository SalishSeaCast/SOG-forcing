%quick correlation check - a year of SH and YVR data
%-9999s are simply flattened to 0,
%vectors not yet rotated to align with SoG

addpath /ocean/mwolfe/RI/matlab/
addpath /ocean/jsklad/matlab/
addpath /ocean/jsklad/Sandhead/

sD = datenum('January 1, 1996 1:00:00 am');
eD = datenum('December 30, 1997 12:00:00 pm');
SHrange = splicefiles_form('/ocean/jsklad/Sandhead/SH/', 'SH', sD, eD);
YVrange = splicefiles_form('/ocean/jsklad/Sandhead/YV/', 'YV', sD, eD);

SHspd = SHrange(:,6);
SHdir = SHrange(:,5);
YVspd = YVrange(:,6);
YVdir = YVrange(:,5);
SHdate = datenum([ SHrange(:,1) , SHrange(:,2) , SHrange(:,3) , SHrange(:,4) , zeros(length(SHrange(:,1)),1) zeros(length(SHrange(:,1)),1) ]);
YVdate = datenum([ YVrange(:,1) , YVrange(:,2) , YVrange(:,3) , YVrange(:,4) , zeros(length(YVrange(:,1)),1) zeros(length(YVrange(:,1)),1) ]);
YVdir = 10.*YVdir;
SHdir = 10.*SHdir;

%eliminate outliers
for i = 1:length(SHspd)
        if abs(SHspd(i)) > 100
            SHspd(i) = 0;
        end
    end
for i = 1:length(YVspd)
        if abs(YVspd(i)) > 100
            YVspd(i) = 0;
        end
end

for i = 1:length(SHdir)
        if abs(SHdir(i)) > 1000
            SHdir(i) = 0;
        end
end
for i = 1:length(YVdir)
        if abs(YVdir(i)) > 1000
            YVdir(i) = 0;
        end
end

%separate out components of wind (adapted from Susan Allen's code)
SHu = SHspd.*sin(SHdir*(pi/180));
SHv = SHspd.*cos(SHdir*(pi/180));
YVu = YVspd.*sin(YVdir*(pi/180));
YVv = YVspd.*cos(YVdir*(pi/180));

%{
% rotate wind 55 degrees clockwise (adapted from Susan Allen's code)
theta = -55*pi/180.;
YVur = YVu*cos(theta)-YVv*sin(theta);
YVvr = YVu*sin(theta)+YVv*cos(theta);
SHur = SHu*cos(theta)-SHv*sin(theta);
SHvr = SHu*sin(theta)+SHv*cos(theta);

% change wind to from direction (adapted from Susan Allen's code)
YVur = -YVur;
YVvr = -YVvr;
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
for i = 1:length(YVdir)
        if (YVdir(i) > 35 && YVdir(i) <= 215)
            YVdirB(i) = 0.1;
        else
            YVdirB(i) = 1.1;
        end
end

SHspdc = SHspd.^3; %windspeed cubed
YVspdc = YVspd.^3;
   
% figure(1)
% clf
% subplot(2,1,1)
% plot(SHdate(1:500), SHspdc(1:500));
% axdate;
% hold
% plot(YVdate(1:500), YVspdc(1:500), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(1:500), SHdirB(1:500));
% axdate;
% hold
% plot(YVdate(1:500), YVdirB(1:500), 'r');
% axdate;
% 
% figure(2)
% clf
% subplot(2,1,1)
% plot(SHdate(500:1000), SHspdc(500:1000));
% axdate;
% hold
% plot(YVdate(500:1000), YVspdc(500:1000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(500:1000), SHdirB(500:1000));
% axdate;
% hold
% plot(YVdate(500:1000), YVdirB(500:1000), 'r');
% axdate;
% 
% figure(3)
% clf
% subplot(2,1,1)
% plot(SHdate(1500:2000), SHspdc(1500:2000));
% axdate;
% hold
% plot(YVdate(1500:2000), YVspdc(1500:2000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(1500:2000), SHdirB(1500:2000));
% axdate;
% hold
% plot(YVdate(1500:2000), YVdirB(1500:2000), 'r');
% axdate;
% 
% figure(4)
% clf
% subplot(2,1,1)
% plot(SHdate(2000:2500), SHspdc(2000:2500));
% axdate;
% hold
% plot(YVdate(2000:2500), YVspdc(2000:2500), 'r');%{
% axdate;
% subplot(2,1,2)
% plot(SHdate(2000:2500), SHdirB(2000:2500));
% axdate;
% hold
% plot(YVdate(2000:2500), YVdirB(2000:2500), 'r');
% axdate;
% 
% figure(5)
% clf
% subplot(2,1,1)
% plot(SHdate(2500:3000), SHspdc(2500:3000));
% axdate;
% hold
% plot(YVdate(2500:3000), YVspdc(2500:3000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(2500:3000), SHdirB(2500:3000));
% axdate;
% hold
% plot(YVdate(2500:3000), YVdirB(2500:3000), 'r');
% axdate;
% 
% figure(6)
% clf
% subplot(2,1,1)
% plot(SHdate(7000:7500), SHspdc(7000:7500));
% axdate;
% hold
% plot(YVdate(7000:7500), YVspdc(7000:7500), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(7000:7500), SHdirB(7000:7500));
% axdate;
% hold
% plot(YVdate(7000:7500), YVdirB(7000:7500), 'r');
% axdate;
% 
% figure(7)
% clf
% subplot(2,1,1)
% plot(SHdate(7500:8000), SHspdc(7500:8000));
% axdate;
% hold
% plot(YVdate(7500:8000), YVspdc(7500:8000), 'r');
% axdate;
% subplot(2,1,2)
% plot(SHdate(7500:8000), SHdirB(7500:8000));
% axdate;
% hold
% plot(YVdate(7500:8000), YVdirB(7500:8000), 'r');
% axdate;

SL = polyfit(SHspd, YVspd, 1);

figure(8)
clf
plot(SHspd, YVspd, '*')
hold
plot(SHspd, SL(1).*SHspd + SL(2), 'g')

SHdirR = SHdir(1:length(SHdir))+10*rand(length(SHdir), 1);
YVdirR = YVdir(1:length(YVdir))+10*rand(length(YVdir), 1);

SD = polyfit(SHdir, YVdir, 1);
figure(9)
clf
plot(SHdirR, YVdirR, '.')
hold
plot(SHdir, SD(1).*SHdir + SD(2), 'g')

figure(10)
clf
plot(SHdir, YVdir, '.')
hold
plot(SHdir, SD(1).*SHdir + SD(2), 'g')

uL = polyfit(YVu, SHu, 1);
uP = polyfit(YVu, SHu, 2);
uC = polyfit(YVu, SHu, 3);
uBC = fminsearch(@func, uL, [ ], YVu, SHu) %combination linear, sqrt

SHuL = uL(1).*YVu+uL(2);
SHuP = uP(1).*YVu.^2 + uP(2).*YVu + uP(3);
SHuC = uC(1).*YVu.^3 + uC(2).*YVu.^2 + uC(3).*YVu + uC(4);
SHuBC = uBC(1).*YVu+uBC(2);

figure(11)
clf
plot(YVu, SHu, '.')
hold
plot(YVu, SHuL, 'g.')
plot(YVu, SHuP, 'm.')
plot(YVu, SHuC, 'y.')
plot(YVu, SHuBC, 'c.')
rUL = sqrt( sum( (SHu(:)-SHuL(:)).^2 ) /numel(SHu));
rUP = sqrt( sum( (SHu(:)-SHuP(:)).^2 ) /numel(SHu));
rUC = sqrt( sum( (SHu(:)-SHuC(:)).^2 ) /numel(SHu));

vL = polyfit(YVv, SHv, 1);
vP = polyfit(YVv, SHv, 2);
vC = polyfit(YVv, SHv, 3);
vBC = fminsearch(@func, vL, [ ], YVv, SHv) %combination linear, sqrt

SHvL = vL(1).*YVv+vL(2);
SHvP = vP(1).*YVv.^2 + vP(2).*YVv + vP(3);
SHvC = vC(1).*YVv.^3 + vC(2).*YVv.^2 + vC(3).*YVv + vC(4);
SHvBC = vBC(1).*YVv+vBC(2);

figure(12)
clf
plot(YVv, SHv, '.')
hold
plot(YVv, SHvL, 'g.')
plot(YVv, SHvP, 'm.')
plot(YVv, SHvC, 'y.')
plot(YVv, SHvBC, 'c.')
rVL = sqrt( sum( (SHv(:)-SHvL(:)).^2 ) /numel(SHv));
rVP = sqrt( sum( (SHv(:)-SHvP(:)).^2 ) /numel(SHv));
rVC = sqrt( sum( (SHv(:)-SHvC(:)).^2 ) /numel(SHv));

rU = [rUL, rUP, rUC];
rV = [rVL, rVP, rVC];