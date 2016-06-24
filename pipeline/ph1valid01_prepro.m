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
%       - Info: summary of a couple of measures
%
%   also writes fieldtrip data structure to out-folder
%   and saves the additional information in the corresponding subject's
%   subjmfile
%   

%import prepro;

%% parsing inputs
if ~exist('subjid','var')
    warning('No subjid provided; using VP16 for testing purposes');
    subjid = 'VP16';
    warn = true;
else
    warn = false;
end;

if ~exist('experiment','var')
    experiment = 'Rp'; 
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
SessionInfo = ph1valid00_setup;


%% reading data file and check if EMG data is there

try
    dataFile = prepro.validate(subjid, experiment, SessionInfo);
catch ME
   Info.(['emg_data_' experiment]) = 'no';
   Info.(['n' experiment 'Trials']) = 0;
   Info.(['isExcluded_' experiment]) = 'yes';
   io.writeToSubjmfile(Info, subjid);
   rethrow(ME);
end;

 Info.(['emg_data_' experiment]) = 'yes';

%% Preprocessing (demean1, demean2, detrend, filter, segment, rectify, ...
[ data ] = prepro.basicPrepro(dataFile, subjid, experiment);

%% collect some basic information on the dataset
eval([subjid '_subjinfo']);

conds = prepro.defineConditions(subjinfo);

conds = conds.(experiment);

% get thresholds and Amplitudes

[ Info, data{1} ] = prepro.getThresholds(data{1}, Info, conds, '', experiment);

%% find errors (reactions ocurring prior to target stimulus)

[ Info, data{1} ] = prepro.getErrors(data{1}, Info, conds, experiment);

if strcmpi(experiment, 'Rp')
    data{2}.trialinfo = data{1}.trialinfo;
    data = data{2};
else
    data = data{1};
end;

% second column data.trialinfo: trialtype
% 60 = early activity in correct channel
% 69 = early acitivity in incorrect channel


%% remove error trials from dataset
Info.(['cleanTrials_' experiment]) = setdiff(1:size(data.trialinfo, 1),Info.(['allErrors_' experiment]));
Info.(['nCleanTrials_' experiment]) = length(Info.(['cleanTrials_' experiment]));
cfg = [];
cfg.trials = Info.(['cleanTrials_' experiment]);
data = ft_selectdata(cfg, data);

data.cfg.event = data.cfg.previous.event;

%% recalculate thresholds
[ Info, data ] = prepro.getThresholds(data, Info, conds, 'clean', experiment);

Info.(['isExcluded_' experiment]) = 'no';

while true
    try
        save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_' experiment '.mat']), 'data');
        break;
    catch
        mkdir(fullfile(SessionInfo.emgPreproDir, subjid));
    end;
end;

io.writeToSubjmfile(Info, subjid);

if warn
    warning('No subjid provided; used VP16 for testing purposes.');
end;



