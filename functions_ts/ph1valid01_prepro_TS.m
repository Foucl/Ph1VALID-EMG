function [ data, Info ] = ph1valid01_prepro_TS( subjid, varargin )
%PH1VALID01_PREPRO basic EMG preprocessing
%   takes a subjid and preprocesses the corresponding bdf recording
%   inputs:
%   - subjid (e.g. 'VP07')
%   - cfg.sgm: segment begin/end (default [2 2.5])
%   - cfg.bsl1: baseline period for rejection of trials with early activity (default [-0.1 0])
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
if exist('subjid','var') == 0
    warning('No subjid provided; using VP46 for testing purposes');
    subjid = 'VP46';
    warn = true;
else
    warn = false;
end;

[input, subjid] =  checkInputs(subjid, varargin{:});


%% checking Setup

SessionInfo = ph1valid_setup;

%% get rid of exluded subjects
excl_nodata = ['VP03';'VP07';'VP08'];

if ismember(subjid,excl_nodata,'rows')
    Info.emg_data = 'no';
    Info.nTsTrials = 0;
    Info.isExcluded = 'yes';
    ph1valid_writeToSubjmfile(Info, subjid);
    error('custom:no_data', 'no EMG data found for %s', subjid);
end;

%% reading data file and check if EMG data is there

try
    dataFile = ph1valid_validate(subjid);
catch
   Info.emg_data = 'no';
   Info.nRpTrials = 0;
   Info.isExcluded = 'yes';
   ph1valid_writeToSubjmfile(Info, subjid);
   return;
end;

Info.emg_data = 'yes';

%% Preprocessing (demean/baseline-cor, filter, segment, rectify, ...)
[ data ] = basicPrepro(dataFile, input, subjid);

%% read happy letter from subjinfo to fix trigger and define conds
eval([subjid '_subjinfo']);

if strcmpi(subjinfo.happy_letter, 'm')
    conds = {'AN_rep' 'AN_swt' 'HA_rep' 'HA_swt';
        [141 142] [151:153] [241 242] [251:253];
        1 1 2 2};
else
    conds = {'AN_rep' 'AN_swt' 'HA_rep' 'HA_swt';
        [241 242] [251:253] [141 142] [151:153] ;
        1 1 2 2};
end;
    
% get thresholds and Amplitudes

[ Info ] = getThresholds(data, Info, conds, '');

%% find errors (reactions ocurring prior to target stimulus)

[ Info, data ] = getErrors(data, Info, conds);

%data{2}.trialinfo = data{1}.trialinfo;
%data = data{2};
% second column data.trialinfo: trialtype
% 60 = early activity in correct channel
% 69 = early acitivity in incorrect channel


%% remove error trials from dataset
Info.cleanTrials_ts = setdiff(1:size(data.trialinfo, 1),Info.allErrors_ts);
cfg = [];
cfg.trials = Info.cleanTrials_ts;
data = ft_selectdata(cfg, data);
data.cfg.event = data.cfg.previous.event;

%% recalculate thresholds
[ Info ] = getThresholds(data, Info, conds, 'clean');

Info.isExcluded = 'no';

% store condition-trigger mapping in data structure (lazy solution)
data.conds = conds;

while true
    try
        save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_ts.mat']), 'data');
        break;
    catch
        mkdir(fullfile(SessionInfo.emgPreproDir, subjid));
    end;
end;

ph1valid_writeToSubjmfile(Info, subjid);

if warn
    warning('No subjid provided; used VP46 for testing purposes.');
end;


function [ data ] = basicPrepro (dataFile, input, subjid)
Info.emg_data = 'yes';
hdr = ImportBDFHeader(dataFile);
Info.date = datetime([hdr.dataDate '_' hdr.dataTime],'InputFormat','dd.MM.yy_HH.mm.ss');

%define trials
cfg = [];                                   % create an empty variable called cfg
cfg.trialdef.prestim = input.sgm(1);                 % in seconds
cfg.trialdef.poststim = input.sgm(2);                  % in seconds
cfg.trialfun = 'trialfun_ph1valid_TS';
cfg.dataset = dataFile;
try
    cfg = ft_definetrial(cfg);
catch ME
    %disp(ME);
    a = strsplit(ME.identifier, '_');
    Info.nTsTrials = str2double(a{2});
    Info.isExcluded = 'yes';
    ph1valid_writeToSubjmfile(Info, subjid);
    rethrow(ME);
end;

[ ~, lastid ] = lastwarn;

Info.nTsTrials = length(cfg.trl);

%%% preprocess
% baseline correction, low pass filter (10Hz, order 2)
cfg.demean          = 'yes';
cfg.baselinewindow  = input.bsl1;
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 10;
cfg.lpfiltord = 2; % for BVA (defaults) compatibility
data = ft_preprocessing(cfg);

bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
bipolar.labelnew  = {'Cor', 'Zyg'};
bipolar.tra       = [
      +1 -1  0  0
       0  0 +1 -1
    ];

data = ft_apply_montage(data, bipolar);
data.trial = cellfun(@abs,data.trial, 'UniformOutput', false);


function [ dataFile ] = ph1valid_validate( subjid )
%PH1VALID_VALIDATERP Checks Validity of TS segment in EMG data
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

% get the folder
dataDir = fullfile(SessionInfo.emgRawDir, subjid);
assert(exist(dataDir, 'dir')==7,'custom:no_data', 'no such directory: %s', dataDir);

% get the file
fname = dir(fullfile(dataDir, '*.bdf'));
assert(~isempty(fname),'custom:no_data', 'No *.bdf file found in %s.', dataDir);

if length(fname) > 1
    warning('multiple *.bdf files found, caution advised');
end;
[~,idx] = max([fname.bytes]);
fname = fname(idx).name;  % take the largest file
%if strcmp(subjid, 'VP01')
dataFile = fullfile(dataDir, fname);

function [input, subjid] =  checkInputs(subjid, varargin)

defSgm = [0.6 2.6];
defBsl1 = [-0.1 0];
defBsl2 = [-0.1 0];
defReThreshold = true;

p=inputParser;

validSubjid = @(x) validateattributes(x,{'char'},{'size',[1,4]});
validRange = @(x) validateattributes(x,{'double'},{'size',[1,2]});
validBool = @(x) validateattributes(x, {'logical'});

p.addRequired('subjid', validSubjid);

p.addParameter('sgm',defSgm, validRange);
p.addParameter('bsl1',defBsl1, validRange);
p.addParameter('bsl2',defBsl2, validRange);
p.addParameter('reThreshold',defReThreshold, validBool);

p.parse(subjid, varargin{:});
input = p.Results;
subjid = input.subjid;


function [ Info ] = getThresholds(data, Info, conds, type)
% recalculate clean thresholds
for i = 1:size(conds,2)
    con = conds{1,i};
    chani = conds{3,i};
    trg = conds{2,i};
    indices = find(ismember(data.trialinfo, trg));
    curdat = data.trial(indices);
    amps = cellfun(@(x) max(x(chani,:)), curdat);
    Info.([con '_' type 'MaxAmp']) = max(amps);
    Info.([con '_' type 'MeanMaxAmp']) = mean(amps);
    Info.([con '_' type 'Threshold']) = 0.25*mean(amps);
    Info.([con '_' type 'nTrials']) = length(curdat);
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
    indices = find(ismember(data.trialinfo, trg));
    curdat = data.trial(indices);
    curtime = data.time(indices);
    
    errorTrials = nan(180,1);
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
Info.nErrors_ts = nErrors;
Info.allErrors_ts = [allErrors{:}];

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