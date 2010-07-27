function[] = multiECconverter(location, tag, startD, endD)

%location = '/ocean/jsklad/Sandhead/EI/';
%tag = 'EI';
%vecStart = datevec('January 1, 2008 0:00:00 am');
%vecEnd = datevec('December 30, 2008 12:00:00 pm');

addpath /ocean/jsklad/Sandhead/
addpath /ocean/jsklad/matlab/

startDa = startD;
endDa = endD;

vecStart = datevec(startDa);
vecEnd = datevec(endDa);

startY = vecStart(1,1);
startM = vecStart(1,2);
endY = vecEnd(1,1);
endM = vecEnd(1,2);

numMonths = endM - startM + 12*(endY - startY) + 1; 

curData = [];
curY = startY;
curM = startM;
for i = 1:numMonths
        loop1 = 1;
        
        if curM < 10
            curFile = sprintf('%s%s_%4i_0%i_', location, tag, curY, curM);
        else
            curFile = sprintf('%s%s_%4i_%i_', location, tag, curY, curM);
        end

        if exist(curFile, 'file') && exist(sprintf('%s_form', curFile), 'file')==0
            curData = ECfilemod(curFile);
        end
        
        if curM < 12
            curM = curM + 1;
        else
            curM = 1;
            curY = curY + 1;
        end
end



