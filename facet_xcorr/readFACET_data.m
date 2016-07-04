function [dat] = readFACET_data(filename, hdr, begsample, endsample, chanindx)

% initialize some variables
nchan = numel(hdr.label);
str   = repmat('%f', [1 nchan]);

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
[time, frame] = dataArray{[9, 13]};
start = find(frame == 1);
start = start(2);
dataArray = dataArray([20:59]);
dat = cell2mat(dataArray);
dat = dat(start:end,:);
fclose(fid);
dat = dat(begsample:endsample, chanindx)';

%TODO: get baseline from header and remove it from (evidence scores?)


