function [ data, Info ] = ph1valid01_prepro( subjid, experiment )
%PH1VALID01_PREPRO basic EMG preprocessing
%   takes a subjid and preprocesses the corresponding bdf recording
%   inputs:
%   - subjid (e.g. 'VP07')
%   - cfg.sgm: segment begin/end (default [2 2.5])
%   - cfg.bsl1: baseline period for rejection of trials with early activity (default [-2 -1.8])
%   - cfg.bsl2: baseline period for actual classification of trials (default [-0.1 0])
%
%
%   returns
%       - fieldtrip data structure
%
%   also writes fieldtrip data structure to out-folder
%   and saves the additional information in the corresponding subject's
%   subjmfile
%   


%% parsing inputs
if ~exist('subjid','var')
    warning('No subjid provided; using VP16 for testing purposes');
    subjid = 'VP16';
    warn = true;
else
    warn = false;
end;

%% set defaults according to experiment
if strcmpi(experiment, 'rp') || strcmpi(experiment, 'priming') || strncmpi(experiment, 'r', 1)
    bl = {[-2 -1.8] [-0.1 0]};
    sgm = [2 2.5];
    experiment = 'Rp';
else %switching
    bl = [-0.1 0];
    sgm = [0.6 2.6];
    experiment = 'Ts';
end;


%% checking Setup
SessionInfo = ph1valid_setup;


%% reading data file and check if EMG data is there

try
    dataFile = ph1valid_validate(subjid, experiment);
catch
   Info.(['emg_data_' experiment]) = 'no';
   Info.(['n' experiment 'Trials']) = 0;
   Info.isExcluded = 'yes';
   ph1valid_writeToSubjmfile(Info, subjid);
   return;
end;

 Info.(['emg_data_' experiment]) = 'yes';

%% Preprocessing (demean1, demean2, detrend, filter, segment, rectify, ...
[ data ] = basicPrepro(dataFile, subjid, experiment);

%% collect some basic information on the dataset
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
% get thresholds and Amplitudes

[ Info ] = getThresholds(data{1}, Info, conds, '');

%% find errors (reactions ocurring prior to target stimulus)

[ Info, data{1} ] = getErrors(data{1}, Info, conds);

data{2}.trialinfo = data{1}.trialinfo;
data = data{2};
% second column data.trialinfo: trialtype
% 60 = early activity in correct channel
% 69 = early acitivity in incorrect channel


%% remove error trials from dataset
Info.cleanTrials = setdiff(1:size(data.trialinfo, 1),Info.allErrors);
cfg = [];
cfg.trials = Info.cleanTrials;

data = ft_selectdata(cfg, data);
data.cfg.event = data.cfg.previous.event;

%% recalculate thresholds
[ Info ] = getThresholds(data, Info, conds, 'clean');

Info.isExcluded = 'no';

while true
    try
        save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro.mat']), 'data');
        break;
    catch
        mkdir(fullfile(SessionInfo.emgPreproDir, subjid));
    end;
end;

ph1valid_writeToSubjmfile(Info, subjid);

if warn
    warning('No subjid provided; used VP16 for testing purposes.');
end;





function [ Info ] = getThresholds(data, Info, conds, type)
% recalculate clean thresholds
for i = 1:size(conds,2)
    con = conds{1,i};
    chani = conds{3,i};
    trg = conds{2,i};
    indices = data.trialinfo == trg;
    curdat = data.trial(indices);
    amps = cellfun(@(x) max(x(chani,:)), curdat);
    Info.([con '_' type 'MaxAmp']) = max(amps);
    Info.([con '_' type 'MeanMaxAmp']) = mean(amps);
    Info.([con '_' type 'Threshold']) = 0.25*mean(amps);
end;

function [ Info, data ] = getErrors(data, Info, conds)
nErrors = 0;
ch_wrong = [conds{3,[3 4 1 2]}];
con_wrong = conds(1, [3 4 1 2]);
allErrors = cell(1,4);
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    chani = conds{3,i};
    chani_o = ch_wrong(i);
    th = Info.([con '_Threshold']);
    th_o = Info.([con_wrong{i} '_Threshold']);
    indices = find(data.trialinfo == trg);
    curdat = data.trial(indices);
    curtime = data.time(indices);
    
    errorTrials = nan(80,1);
    k = 1;
    for j = 1:length(curdat)
        idx = find(curdat{j}(chani,:) >= th, 1);  % indices of 'hits': => threshold in correct channel
        idx_o = find(curdat{j}(chani_o,:) >=th_o,1); % indices of hits-in-wrong-channel: wrong emotions shown
        if ~isempty(idx_o) && (curtime{j}(idx_o) < 0) && (-0.5 < curtime{j}(idx_o))   % current trial is wrong
            errorTrials(k) = indices(j);
            data.trialinfo(indices(j),2) = 69;
            k = k +1;
        elseif ~isempty(idx) && (curtime{j}(idx) < 0) && (-0.5 < curtime{j}(idx))
            errorTrials(k) = indices(j);
            data.trialinfo(indices(j),2) = 60;
            k = k+1;
        else
            data.trialinfo(indices(j),2) = nan;
        end;
    end;
    errorTrials(isnan(errorTrials)) = [];
    Info.([con '_errorTrials']) = errorTrials.';
    Info.([con '_nErrorTrials']) = length(errorTrials);
    allErrors{i} = errorTrials';
    nErrors = nErrors + length(errorTrials);
end;
Info.nErrors = nErrors;
Info.allErrors = [allErrors{:}];

% function data = concatVP14 (input, SessionInfo)
% dataDir = fullfile(SessionInfo.emgRawDir, 'VP14');
% fname = dir(fullfile(dataDir, '*.bdf'));
% 
% dataFile = [];
% dataFile.A = fullfile(dataDir, fname(1).name);
% dataFile.B = fullfile(dataDir, fname(2).name);
% 
% dat.A = basicPrepro(dataFile.A, input);
% dat.B = basicPrepro(dataFile.B, input);
% 
% data = ft_appenddata([], dat.A, dat.B);