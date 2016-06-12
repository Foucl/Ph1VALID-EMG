function [ data, Info ] = ph1valid01_prepro( subjid, varargin )
%PH1VALID01_PREPRO basic EMG preprocessing
%   takes a subjid and preprocesses the corresponding bdf recording
%   inputs:
%   - subjid (e.g. 'VP07')
%   - cfg.sgm: segment begin/end (default [2 2.5])
%   - cfg.bsl1: baseline period for rejection of trials with early activity (default [-2 -1.8])
%   - cfg.bsl2: baseline period for actual classification of trials (default [-0.2 0])
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

defSgm = [2 2.5];
defBsl1 = [-2 -1.8];
defBsl2 = [-0.1 0];

p=inputParser;

validSubjid = @(x) validateattributes(x,{'char'},{'size',[1,4]});
validRange = @(x) validateattributes(x,{'double'},{'size',[1,2]});
p.addRequired('subjid',validSubjid);

p.addParameter('sgm',defSgm, validRange)
p.addParameter('bsl1',defBsl1, validRange)
p.addParameter('bsl2',defBsl2, validRange)

p.parse(subjid,varargin{:});
input = p.Results;

%% checking Setup

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

%% reading data file
%%% checking folder

dataFile = ph1valid_validateRP(subjid);

if strcmp(subjid, 'VP14')
    data = concatVP14(input, SessionInfo);
else
    data = basicPrepro(dataFile, input);
end;


%%% Create Montages (re-referencing)
bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
bipolar.labelnew  = {'Cor', 'Zyg'};
bipolar.tra       = [
      +1 -1  0  0
       0  0 +1 -1
    ];
data = ft_apply_montage(data, bipolar);

%%% rectify
data.trial = cellfun(@abs,data.trial, 'UniformOutput', false);

%% collect some basic information on the dataset
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
%%% get thresholds
Info = [];
for i = 1:size(conds,2)
    con = conds{1,i};
    chani = conds{3,i};
    trg = conds{2,i};
    indices = find(data.trialinfo == trg);
    curdat = data.trial(indices);
    amps{i} = cellfun(@(x) max(x(chani,:)), curdat);
    if mod(i,2) == 0
        j = i-1;
    else
        j = i;
    end;
    Info.([con '_max_amp']) = max(amps{j});
    Info.([con '_mean_max_amp']) = mean(amps{j});
    Info.([con '_Threshold']) = 0.25*mean(amps{j});
end;

%%% classify early activity
nErrors = 0;
allErrors = [];
htype=[];
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    chani = conds{3,i};
    th = Info.([con '_Threshold']);
    indices = find(data.trialinfo == trg);
    curdat = data.trial(indices);
    curtime = data.time(indices);
    %cursample = data.sampleinfo(indices);
    
    switch i
       case 1
           th_o = Info.([conds{1,3} '_Threshold']);
           chani_o = 2;
       case 2
           th_o = Info.([conds{1,4} '_Threshold']);
           chani_o = 2;
       case 3
           th_o = Info.([conds{1,1} '_Threshold']);
           chani_o = 1;
       case 4
           th_o = Info.([conds{1,2} '_Threshold']);
           chani_o = 1;
    end;
    
    errorTrials = [];
    for j = 1:length(curdat)
        idx = find(curdat{j}(chani,:) >= th, 1);  % indices of 'hits': => threshold in correct channel
        idx_o = find(curdat{j}(chani_o,:) >=th_o,1); % indices of hits-in-wrong-channel: wrong emotions shown
        if (curtime{j}(idx_o) < 0) & (-0.5 < curtime{j}(idx_o))   % current trial is wrong
            errorTrials = [errorTrials indices(j)];
            data.trialinfo(indices(j),2) = 69;
        elseif (curtime{j}(idx) < 0) & (-0.5 < curtime{j}(idx))
            errorTrials = [errorTrials indices(j)];
            data.trialinfo(indices(j),2) = 60;
        else
            data.trialinfo(indices(j),2) = nan;
        end;
    end;
    Info.([con '_errorTrials']) = errorTrials;
    Info.([con '_nErrorTrials']) = length(errorTrials);
    allErrors = [allErrors errorTrials];
    nErrors = nErrors + length(errorTrials);
end;

% second column data.trialinfo: trialtype
% 60 = early activity in correct channel
% 69 = early acitivity in incorrect channel

Info.nErrors = nErrors;
Info.allErrors = allErrors;

%% remove error trials from dataset
Info.cleanTrials = setdiff(1:size(data.trialinfo, 1),allErrors);
cfg = [];
cfg.trials = Info.cleanTrials;
data = ft_selectdata(cfg, data);

%% re-preprocess data with different baseline (immediately preceding target)
cfg = [];
cfg.demean          = 'yes';
cfg.baselinewindow  = input.bsl2;
data = ft_preprocessing(cfg, data);

%% recalculate clean thresholds
% for i = 1:size(conds,2)
%     con = conds{1,i};
%     chani = conds{3,i};
%     trg = conds{2,i};
%     indices = find(data.trialinfo == trg);
%     curdat = data.trial(indices);
%     amps = cellfun(@(x) max(x(chani,:)), curdat);
%     Info.([con '_max_amp']) = max(amps);
%     Info.([con '_mean_max_amp']) = mean(amps);
%     Info.([con '_cleanThreshold']) = 0.25*mean(amps);
% end;

mkdir(fullfile(SessionInfo.emgPreproDir, subjid));
save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro.mat']), 'data');

ph1valid_writeToSubjmfile(Info, subjid);


function data = basicPrepro (dataFile, input)
%define trials
cfg = [];                                   % create an empty variable called cfg
cfg.trialdef.prestim = input.sgm(1);                 % in seconds
cfg.trialdef.poststim = input.sgm(2);                  % in seconds
cfg.trialfun = 'trialfun_ph1valid';
cfg.dataset = dataFile;
cfg = ft_definetrial(cfg);

%%% preprocess
% baseline correction, low pass filter (10Hz, order 2)
cfg.demean          = 'yes';
cfg.baselinewindow  = input.bsl1;
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 10;
cfg.lpfiltord = 2; % for BVA (defaults) compatibility
data = ft_preprocessing(cfg);


function data = concatVP14 (input, SessionInfo)
dataDir = fullfile(SessionInfo.emgRawDir, 'VP14');
fname = dir(fullfile(dataDir, '*.bdf'));

dataFile = [];
dataFile.A = fullfile(dataDir, fname(1).name);
dataFile.B = fullfile(dataDir, fname(2).name);

dat.A = basicPrepro(dataFile.A, input);
dat.B = basicPrepro(dataFile.B, input);

data = ft_appenddata([], dat.A, dat.B);



