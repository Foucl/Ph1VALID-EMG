function [hdr] = readFACET_hdr(filename)

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
label = label([20:59]);
ncol  = numel(label);
[time, frame] = dataArray{[9, 13]};
start = find(frame == 1);
start = start(2);
time = time(start:end);
frame = frame(start:end);

nSmpl = size(time, 1);
nMs = time(nSmpl);
nS = (nMs/1000);
nFrame = frame(nSmpl);
fps = nFrame/nS;
Fs = fps;

% create the output
hdr          = [];
hdr.Fs       = Fs;
hdr.label    = label;
hdr.nTrials  = 1;
hdr.nSamples = nSmpl;
hdr.nSamplesPre = 0;
hdr.nChans   = ncol;
%hdr.time     = time; % events in the raw event file have both a sample and a time stamp