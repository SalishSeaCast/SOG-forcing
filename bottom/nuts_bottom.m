load nuts.mat
      
total_cruises=length(nuts.no3(:,3));

% Special Cruises (patch data)

% Cruise 1: only 3 data points: assume 20 m nitrate same downward

no3(1)=nuts.no3(1,3);
si(1)=nuts.si(1,3);
ratio(1)=nuts.chl_020(1,3)/nuts.chl_200(1,3);

% Cruise 11: no 30 m data: assume 10 m nitrate same downward
no3(11) = nuts.no3(11,3);
si(11) = nuts.no3(11,3);
ratio(11)=nuts.chl_020(11,3)/nuts.chl_200(11,3);

% Cruise 45: there is no data!

for i=2:10;
     no3(i)=nuts.no3(i,4);
     si(i) = nuts.si(i,4);
ratio(i)=nuts.chl_020(i,3)/nuts.chl_200(i,3);
end
     for i=12:44;
     no3(i)=nuts.no3(i,4);
     si(i) = nuts.si(i,4);
ratio(i)=nuts.chl_020(i,3)/nuts.chl_200(i,3);
end
     for i=46:total_cruises;
     no3(i)=nuts.no3(i,4);
     si(i) = nuts.si(i,4);
ratio(i)=nuts.chl_020(i,3)/nuts.chl_200(i,3);
end


     fid = ['Nuts_bottom.txt'];
for i=1:total_cruises;
if (i ~= 45)
     y(i,:) = [i no3(i) si(i) ratio(i)];
end
end
save (fid,'y','-ascii')





