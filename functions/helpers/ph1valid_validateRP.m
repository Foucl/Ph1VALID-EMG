function [ dataFile ] = ph1valid_validateRP( subjid )
%PH1VALID_VALIDATERP Checks Validity of RP segment in EMG data
%   returns file handle

p=inputParser;

validSubjid = @(x) validateattributes(x,{'char'},{'size',[1,4]});
p.addRequired('subjid',validSubjid);

p.parse(subjid);

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

dataDir = fullfile(SessionInfo.emgRawDir, subjid);
assert(exist(dataDir, 'dir')==7,'custom:no_data', 'no such directory: %s', dataDir);

% get the file
fname = dir(fullfile(dataDir, '*.bdf'));
assert(~isempty(fname),'custom:no_data', 'No *.bdf file found in %s.', dataDir);

if length(fname) > 1
    warning('multiple *.bdf files found, caution advised'); %TODO: automatically concatenate the files
end;
[~,idx] = max([fname.bytes]);
fname = fname(idx).name;  % take the largest file
%if strcmp(subjid, 'VP01')
dataFile = fullfile(dataDir, fname);
    

% function dataFile = concatVP14
% 
% dataDir = fullfile(SessionInfo.emgRawDir, 'VP14');
% fname = dir(fullfile(dataDir, '*.bdf'));
% 
% dataFile = [];
% dataFile.A = fullfile(dataDir, fname(1).name);
% dataFile.B = fullfile(dataDir, fname(2).name);
