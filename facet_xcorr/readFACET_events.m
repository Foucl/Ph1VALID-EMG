function [event] = readFACET_events(filename)

SessionInfo = ph1valid00_setup;
fc_dir = fullfile(SessionInfo.dataDir, 'FACET');
if nargin < 1
 filename = fullfile(fc_dir, 'Dump046_VP46.txt');
end;
fid = fopen(filename, 'r');

delimiter = '\t';
startRow = 7;

 %get rid of first lines
 firstlines = textscan(fid,         '%[^\n]',6);
 label = textscan(firstlines{1}{6}, '%[^\t]');
label = label{1};
ncol  = numel(label);
str   = ['%s%{yyyyMMdd}D%s%f%s%s%s%s', repmat('%f', [1 ncol-14]), '%s%s%f%s%s%s%f%f'];
dataArray = textscan(fid, str, 'Delimiter', delimiter, 'ReturnOnError', false);

allTriggers = dataArray{62}(~isnan(dataArray{62}));
trInd = ~isnan(dataArray{62});

[time, frame, typ, ev] = dataArray{[10, 13,60, 62]};
ev = num2cell(ev(trInd))';
time = num2cell(time(trInd))';
typ = typ(trInd)';
frame = num2cell(frame(trInd))';
fclose(fid);
event  = struct('sample', frame, 'timestamp', time, 'type', typ, 'value', ev);