function [ SubjInfo ] = ph1valid_getSubjFiles( force )
%PH1VALID_GET Summary of this function goes here
%   Detailed explanation goes here

isLoop = true;
subjid = 'VP09';

SessionInfo = ph1valid_setup;

presentationDir = SessionInfo.presentationDir;
outDir = SessionInfo.outDir;
subjmfileDir = SessionInfo.subjmfileDir;

if nargin < 1
    force = false;
    %subjid = 'VP09';
end;

% SubjVars = parsePresLog(subjid, presentationDir);
% SubjInfoTemplate = structfun(@(x) (nan),SubjInfoTemplate, 'UniformOutput',0);
% save('SubjInfoTemplate.mat', 'SubjInfoTemplate');
load('SubjInfoTemplate.mat');

if ~isLoop
    SubjVars = parsePresLog(subjid, presentationDir, SubjInfoTemplate);
    SubjInfo = SubjVars;
else %loop over all files
    availablePresFiles = ls(presentationDir);
    availablePresFiles = availablePresFiles(4:end,1:4);
    existingSubjmfiles = ls(subjmfileDir);
    existingSubjmfiles = existingSubjmfiles(3:end,1:end-11);
    if force==false 
        toLoop = setdiff(availablePresFiles, existingSubjmfiles, 'rows');
    else
        toLoop = availablePresFiles;
    end;
    for i = 1:size(toLoop,1)
       SubjInfo(i) = parsePresLog(toLoop(i,:), presentationDir, SubjInfoTemplate);
    end;
end;

if ~exist('SubjInfo', 'var')
    warning('All available infofiles already converted - nothing to do');
    return;
end;
%now everything is ready inside SubjInfo
ph1valid_writeToSubjmfile(SubjInfo);
if isLoop
    clear SubjInfo;
end;



function [ SubjVars ] = parsePresLog ( subjid, path, template )
% reads subjinfo-file and returns variables in structure SubjVars
%slCharacterEncoding('ISO-8859-1');
slCharacterEncoding('Windows-1252');
presFolder = fullfile(path, subjid);
FnameObj = dir(fullfile(presFolder, '*subjinfo.tsv'));
fname = FnameObj.name;
file = fullfile(presFolder, fname);

s = tdfread(file);
if isempty(fieldnames(s))
    error(['Problem with subject ' subjid]);
end
s = struct2cell(s);
SubjVars = template;
SubjVars.subjid = subjid;
%SubjVars.date = FnameObj.date;   % not working well; better done via
%biosemi-header
for i = 1:size(s{1},1)
    var = strtrim(s{1}(i,:));
    val = s{2}(i,:);
    if ~isnumeric(val)
        val = strtrim(val);
    end;
    if isstrprop(val, 'digit')
        val = str2num(val);
    elseif strcmpi(val, 'nan')
        val = nan;
    end;
    SubjVars.(var) = val;
end;
return;

