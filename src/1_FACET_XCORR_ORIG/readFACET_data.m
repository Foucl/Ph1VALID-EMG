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


delimiter = '\t';
startRow = 7;
 %get rid of first lines
 firstlines = textscan(fid,         '%[^\n]',6);
 label = textscan(firstlines{1}{6}, '%[^\t]');
label = label{1};
indLast = numel(label);
tmp = strfind(label,'NoOfFaces');
indBeg = find(not(cellfun('isempty', tmp)));
label = label(indBeg:end-6);
ncol  = numel(label);
%str   = ['%s%{yyyyMMdd}D%s%f%s%s%s%s', repmat('%f', [1 ncol-14]), '%s%s%f%s%s%s%f%f'];
%str   = ['%s%s%s%f%s%s%s%s', repmat('%f', [1 ncol-14]), '%s%s%f%s%s%s%f%f'];
ignoredCols_end = indLast-ncol-indBeg + 1;
str   = [ repmat('%*s', [1 (indBeg -1)]), repmat('%f', [1 ncol]) ' %*[^\n]'];

dataArray = textscan(fid, str, endsample-begsample + 1, 'Delimiter', delimiter,...
        'ReturnOnError', false, 'HeaderLines', begsample, 'EmptyValue', -9999);

fclose(fid);


dat = cell2mat(dataArray);
%dat = dat(start:end,:);

% kill the negative evidence scores:
%dat( dat<0 )=0; 

nans = numel(dat(isnan(dat)));

dat = dat(:, chanindx)';

%TODO:10 get baseline from header and remove it from (evidence scores?)


