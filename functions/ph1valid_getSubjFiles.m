pathfunction [ SubjInfo ] = ph1valid_getSubjFiles( subjid )
%PH1VALID_GET Summary of this function goes here
%   Detailed explanation goes here

isLoop = false;


global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

presentationDir = SessionInfo.presentationDir;
outDir = SessionInfo.outDir;
subjmfileDir = SessionInfo.subjmfileDir;

if nargin < 1
    isLoop = true;
    %subjid = 'VP09';
end;

if ~isLoop
    SubjVars = parsePresLog(subjid, presentationDir);
    SubjInfo = SubjVars;
else %loop over all files
    availablePresFiles = ls(presentationDir);
    availablePresFiles = availablePresFiles(5:end,:);
    existingSubjmfiles = ls(subjmfileDir);
    existingSubjmfiles = existingSubjmfiles(3:end,1:end-11);
    toLoop = setdiff(availablePresFiles, existingSubjmfiles, 'rows');
    for i = 1:length(toLoop)
        SubjInfo(i) = parsePresLog(toLoop(i,:), presentationDir);
    end;
end;

if ~exist('SubjInfo', 'var')
    warning('All available infofiles already converted - nothing to do');
    return;
end;
%now everything is ready inside SubjInfo
ph1valid_writeToSubjmfile(SubjInfo);

end

function [ SubjVars ] = parsePresLog ( subjid, path )
% reads subjinfo-file and returns variables in structure SubjVars
slCharacterEncoding('ISO-8859-1');
presFolder = fullfile(path, subjid);
FnameObj = dir(fullfile(presFolder, '*subjinfo.tsv'));
fname = FnameObj.name;
file = fullfile(presFolder, fname);

s = tdfread(file);
if isempty(fieldnames(s))
    error(['Problem with subject ' subjid]);
end
s = struct2cell(s);
SubjVars.subjid = subjid;
SubjVars.date = FnameObj.date;
for i = 1:length(s{1})
    var = strtrim(s{1}(i,:));
    val = strtrim(s{2}(i,:));
    if isstrprop(val, 'digit')
        val = str2num(val);
    end;
    SubjVars.(var) = val;
end;

end