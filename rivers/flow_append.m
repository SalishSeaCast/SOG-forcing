% % Code to append river flow file - READ INSTRUCTIONS CAREFULLY
% 
% Accepts a file containing the source code of Environment Canada real time
% tabulated data for river flow
% (eg. http://www.wateroffice.ec.gc.ca/graph/graph_e.html?stn=08HB002 - click 'Tabular data')
% The table should be set to display Discharge in the first column after date.
% Starting date should be the day after the last day in the original
% dataset
%
% The expected format of the html table rows is:
% <tr class="darkBg">
% <td>2010-06-09 02:02:04</td>
% <td>12.36</td>                  %discharge
% <td>12.36</td>                  %discharge or other parameter
% </tr>

clear all;
A = fopen('/ocean/jsklad/sog/fraser_html09-10'); %Environment Canada source code
load /ocean/jsklad/sog/fraser_extended.dat
orig_data = fraser_extended;

head = true;
head2 = true;

while head == true %skips down to the data table, marked by table ID "dataTable"
    line = fgetl(A);
    if strfind(line, 'dataTable')
        while head2 == true %skips the table info for "dataTable"
            line = fgetl(A);
            if strfind(line, 'tbody')
                head2 = false;
            end
        end
        head = false;
    end
end

date = [];
flow = [];
flag = false;
next = false;           
        
while flag == false
    line = fgetl(A);
        if strcmp(line, '</tbody>') %breaks loop at end of table body
            flag = true;
            break
        elseif ~isempty(line)
            if length(line) > 24 %then this line contains a date and time
                nlineS = regexprep(line, '<td>', '');
                nlineS = regexprep(nlineS, '</td>', '');
                nlineS = regexprep(nlineS, '-', ' ');
                nlineS = regexprep(nlineS, '/', ' ');
                nlineS = regexprep(nlineS, ':', ' ');
                nlineS = regexprep(nlineS, ',', ' ');
                nlineS = regexprep(nlineS, '\t', ' ');

                nlineF = textscan(nlineS, '%f %f %f %f %f %f');
                date = [ date ; nlineF(:,1) nlineF(:,2) nlineF(:,3) nlineF(:,4) ];
                next = true; %flags the next line with data as the flow value for this date
            elseif next == true
                nlineS = regexprep(line, '<td>', '');
                nlineS = regexprep(nlineS, '</td>', '');
                nlineF = textscan(nlineS, '%f');
                flow = [flow ; nlineF];
                next = false;
            end
        end
end

data = [date, flow];
ndata = [];
nrow = 1;
daytotal = 0;
daycount = 0;

for row = 1:length(data)
    if ((row == 1) || (data{row,3} == data{row-1,3})) && row ~= length(data)%if data on this line is from same day as prev line
        daytotal = daytotal + data{row,5};
        daycount = daycount + 1;
    elseif row == length(data); %to collect average from final day
        daytotal = daytotal + data{row,5};
        daycount = daycount + 1;
        dayflow = daytotal/daycount;
        ndata = [ndata; data{row-1,1}, data{row-1,2}, data{row-1,3}, dayflow];
    else %each new day
        dayflow = daytotal/daycount;
        ndata = [ndata; data{row-1,1}, data{row-1,2}, data{row-1,3}, dayflow];
        daytotal = data{row,5};
        daycount = 1;
    end
end

total_data = [orig_data; ndata];
dlmwrite('fraser_total.dat', total_data, ' ');


