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
assert(exist(dataDir, 'dir')==7, 'no such directory: %s', dataDir);

% get the file
fname = dir(fullfile(dataDir, '*.bdf'));
assert(~isempty(fname), 'No *.bdf file found in %s.', dataDir);

if length(fname) > 1
    warning('multiple *.bdf files found, caution advised'); %TODO: automatically concatenate the files
end;
fname = fname(find(max([fname.bytes]))).name;  % take the largest file
dataFile = fullfile(dataDir, fname);
    


end

