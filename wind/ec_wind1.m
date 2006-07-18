%2003/10/11 00:08:00 WEL SA 0000 AUTO8 M M M 189/12/10/1008/M/ 0002 ?07MM?=
%   File timestamp         obstime
%                                           press
%                                              temp
%                                               dew point?
%                                                     wind spd/dir
%                                                                     tenths for
%                                                                    temp (and dew?)
% 
% 15m above MSL.
% Tricky part here is that Air temp is split into two places.

sand=struct('comment','Time UTC, speed|dir m/s|deg, Temp deg C',...
            'mtime',NaN+zeros(365*2*24,1),...
            'press',NaN+zeros(365*2*24,1),...
            'dewpoint',NaN+zeros(365*2*24,1),...
            'wspeed',NaN+zeros(365*2*24,1),...
            'wdir',NaN+zeros(365*2*24,1),...
	    'airtemp',NaN+zeros(365*2*24,1));

fd=fopen('TEXT_HOURLIES_WVF_20050405-20050704.txt');lkkk=[1];

k=0;
for kkk=lkkk,
l=fgets(fd);

while l(1)>-1,
  if length(l)>50 & l(1)~='%' & l(24)~='1';
     k=k+1;
 
     mdate=datenum([l(6:7) '-' l(9:10) '-' l(1:4)]);
     stampdate=datenum(l(12:19));
     obsdate=datenum([l(28:29) ':00:00']);
     if stampdate>=obsdate,
       sand.mtime(k)=mdate+obsdate;
     else
       sand.mtime(k)=mdate-1+obsdate;
     end;  
     if l(45)~='M',
       sand.press(k)=str2num(l(45:47))/10;
       if sand.press(k)<60,
        sand.press(k)=sand.press(k)+1000;
       else
        sand.press(k)=sand.press(k)+900;
       end;
     end;
     l2=find(l=='?');
     tenths=0;tenths2=0;
     if length(l2)==2 & l(l2(1)+1)~='M',
      if l(l2(1)+1)=='-',
       tenths=sscanf(l(l2(1)+[1:2]),'%d');
       if l(l2(1)+3)~=''M',  %'
	 tenths2=sscanf(l(l2(1)+[3:4]),'%d');
       end;
      else 
       tenths=sscanf(l(l2(1)+[1]),'%d');
       if l(l2(1)+2)~='M',
   	 tenths2=sscanf(l(l2(1)+[2:3]),'%d');
       end;  
      end;
     end;	     

     ll=find(l=='/');

     if l(ll(3)+1)~='M',
       sand.airtemp(k)=str2num(l((ll(3)+1):(ll(4)-1)));
	 if tenths>=5,
	  sand.airtemp(k)=sand.airtemp(k)-1+tenths/10;
	 else
	  sand.airtemp(k)=sand.airtemp(k)+tenths/10;
	 end;
     end;	   
     if l(ll(4)+1)~='M',
       sand.dewpoint(k)=str2num(l((ll(4)+1):(ll(5)-1)));
	 if tenths2>=5,
	  sand.dewpoint(k)=sand.dewpoint(k)-1+tenths2/10;
	 else
	  sand.dewpoint(k)=sand.dewpoint(k)+tenths2/10;
	 end;
     end;	   
     if l(ll(5)+1)~='M',
       sand.wdir(k)=str2num(l(ll(5)+[1:2]))*10;
     end;
     if l(ll(5)+3)~='M',  
       sand.wspeed(k)=str2num(l(ll(5)+[3:4]))*0.51444;
     end;  
   end;
 l=fgets(fd); 
 if rem(k,1000)==1, fprintf('.'); end;
end;
fclose(fd);
k
end

ll=finite(sand.mtime);
sand.mtime(~ll)=[];
sand.wspeed(~ll)=[];
sand.wdir(~ll)=[];
sand.airtemp(~ll)=[];
sand.press(~ll)=[];
sand.dewpoint(~ll)=[];

list=fieldnames(sand)'; %'
[a,ind]=sort(sand.mtime);
for i=1:length(list),
  if i~=1,
    eval(['sand.' list{i} '=sand.' list{i} '(ind);'])
  end
end

save sandhead_apr2005-jul2005 sand

return
