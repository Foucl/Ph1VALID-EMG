function [dat] = readFACET_data(filename, hdr, begsample, endsample, chanindx)

% initialize some variables
nchan = numel(hdr.label);
str   = repmat('%f', [1 nchan]);

begsample = begsample + hdr.offset;
endsample = endsample + hdr.offset;

SessionInfo = ph1valid00_setup;
fc_dir = fullfile(SessionInfo.dataDir, 'FACET');
if nargin < 1
    filename = fullfile(fc_dir, 'Dump046_VP46.txt');
end;
fid = fopen(filename, 'r');


%a = dlmread(filename,'\t', 7, 1, );
%columns 9-59

delimiter = '\t';
startRow = 7;
 %get rid of first lines
 firstlines = textscan(fid,         '%[^\n]',6);
 label = textscan(firstlines{1}{6}, '%[^\t]');
label = label{1};
label = label(9:59);
ncol  = numel(label);
%str   = ['%s%{yyyyMMdd}D%s%f%s%s%s%s', repmat('%f', [1 ncol-14]), '%s%s%f%s%s%s%f%f'];
%str   = ['%s%s%s%f%s%s%s%s', repmat('%f', [1 ncol-14]), '%s%s%f%s%s%s%f%f'];
str   = ['%*s%*s%*s%*s%*s%*s%*s%*s', repmat('%f', [1 ncol]), '%*s%*s%*s%*s%*s%*s%*s%*s'];

dataArray = textscan(fid, str, endsample-begsample, 'Delimiter', delimiter, 'ReturnOnError', false, 'HeaderLines', begsample);

fclose(fid);

[time, frame] = dataArray{[1, 5]};
%start = find(frame == 1);
%start = start(2);
dataArray = dataArray([12:51]);
dat = cell2mat(dataArray);
%dat = dat(start:end,:);

% kill the negative evidence scores:
dat( dat<0 )=0; 


dat = dat(:, chanindx)';

%TODO: get baseline from header and remove it from (evidence scores?)


