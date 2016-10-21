subjid = 'VP07';
experiment = 'Rp';
bl = {[-2 -1.8] [-0.1 0]};
sgm = [2 2.5];

%% get original analysis results

eval([subjid '_subjinfo']); % -> struct subjinfo
vars = fieldnames(subjinfo);
varsEarlyTh = export.cellGrep(vars, '_Threshold_Rp');
varsLateTh = export.cellGrep(vars, '_cleanThreshold_Rp');

for i = 1:numel(varsEarlyTh)
    varsEarlyTh{i}
    subjinfo.(varsEarlyTh{i})
end

%% redo original analysis

[dat info] = ph1valid01_prepro(subjid, experiment);

%% checking Setup
SessionInfo = ph1valid00_setup;


%% reading data file and check if EMG data is there
dataFile = prepro.validate(subjid, experiment, SessionInfo);


%% Preprocessing (demean1, demean2, detrend, filter, segment, rectify, ...
[ data ] = prepro.basicPrepro(dataFile, subjid, experiment);

data_earlyBl = data{1};
data_lateBl = data{2};

%% manually read raw data without baseline (but with filter)
cfg = [];
cfg.trialdef.prestim = sgm(1);
cfg.trialdef.poststim = sgm(2);
cfg.trialfun = 'trialfun_ph1valid_Rp';
cfg.dataset = dataFile;
cfg = ft_definetrial(cfg);

cfg.demean          = 'no';
% cfg.baselinewindow  = bl{1};
cfg.lpfilter        = 'no';
cfg.lpfreq          = 10;
cfg.lpfiltord = 2; % for BVA (defaults) compatibility
dataRawEarly = ft_preprocessing(cfg);

% create montage
bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
bipolar.labelnew  = {'Cor', 'Zyg'};
bipolar.tra       = [
    +1 -1  0  0
    0  0 +1 -1
    ];
dataRawEarly = ft_apply_montage(dataRawEarly, bipolar);

% rectify
dataRawEarly.trial = cellfun(@abs,dataRawEarly.trial, 'UniformOutput', false);

cfg = [];
cfg.ylim = [6000, 7000];
cfg.channel = 'Zyg';
ft_databrowser(cfg, dataRawEarly);

% -> linearer trend in den daten: 'wandern' von ~6000µV -> >9000µV

%% baseline correct
cfg = [];
cfg.demean          = 'yes';
cfg.baselinewindow  = bl{1};
dataRawEarly_bl = ft_preprocessing(cfg, dataRawEarly);

% get events/trigger back
dataRawEarly_bl.cfg.event = dataRawEarly_bl.cfg.previous.event;

% show data
cfg = [];
cfg.channel = 'Zyg';
%ft_databrowser(cfg, dataRawEarly_bl);
ft_databrowser(cfg, dataRawEarly_bl);

%% generate trialinfo table
trls = dataRawEarly.trialinfo;
trlnum = 1:length(trls);
trls = [trlnum.', trls];


%% add threshold-channels
%dat = dataRawEarly_bl;
th = subjinfo.HA_val_Threshold_Rp;
for i = 1:length(dat.trial)
    dat.trial{i}(3,:) = th;
end;
dat.label{3} = 'Th_HAVal';

% show data
cfg = [];
%cfg.channel = {'EXG3', 'EXG4'};
cfg.channel = {'Zyg'};
%cfg.ylim= [-6700, -6400];
%ft_databrowser(cfg, dataRawEarly_bl);
ft_databrowser(cfg, dat);