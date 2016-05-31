%% DOCUMENT TITLE
% INTRODUCTORY TEXT
%% SECTION TITLE
% DESCRIPTIVE TEXT
%% SECTION TITLE
% DESCRIPTIVE TEXT
%%



%% setup

ph1valid_setup;

subjid = 'VP25';

% find CNT file of subject 25
fname = dir(fullfile(emg_path, subjid, '*.bdf'));
fname = fname.name;
data_file = fullfile(emg_path, subjid, fname);

%% loading in fieldtrip

% basic prepro: downsample, filter, rectify (?)
% get all Response Priming trials:

 cfg = [];                                   % create an empty variable called cfg
 cfg.trialdef.prestim = 1.9;                 % in seconds
 cfg.trialdef.poststim = 1.5;                  % in seconds
 cfg.trialdef.eventvalue = [51 52 62 61];
 cfg.trialdef.eventtype = 'STATUS';

 cfg.trialfun = 'ft_trialfun_general';
 cfg.dataset = data_file;
 cfg.headerfile = data_file;
 cfg = ft_definetrial(cfg);
% baseline correction
cfg.demean          = 'yes';
cfg.baselinewindow  = [-1.8 0];
% Fitering
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 10;
cfg.lpfiltord = 2; % for BVA (defaults) compatibility
%cfg.rectify = 'yes';
data = ft_preprocessing(cfg);

% Create Montages (re-referencing)
bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
bipolar.labelnew  = {'Cor', 'Zyg'};
bipolar.tra       = [
      +1 -1  0  0
       0  0 +1 -1
    ];
data = ft_apply_montage(data, bipolar);

%data.trial = cellfun(@abs,data.trial, 'UniformOutput', false);

% data_orig = data; %save the original data for later use
%cfg            = [];
%cfg.resamplefs = 768;
%cfg.detrend    = 'no';
%cfg.sampleindex = 'yes';
%data_ds           = ft_resampledata(cfg, data);

% http://mailman.science.ru.nl/pipermail/fieldtrip/2015-March/009054.html
% http://mailman.science.ru.nl/pipermail/fieldtrip/2014-January/007427.html

 
 cfg = [];
 %cfg.dataset = data;
 cfg.channel = 'Cor';
 cfg.continuous = 'no';
 cfg.viewmode = 'vertical';
 cfg.selectmode = 'marktroughevent';
 ft_databrowser(cfg, data);
 %ft_databrowser(cfg, data_AN_prep);

% split data into four conditions
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        'Cor' 'Cor' 'Zyg' 'Zyg'};
    
data_by_con = cell(2,4);

 for i = 1:length(conds)
     con = conds{1,i};
     trg = conds{2,i};
     chan = conds{3,i};
     data_by_con{1,i} = con;
     
     cfg = [];
     %cfg.channel = chan; not a good idea
     cfg.trials = find(data.trialinfo == trg);
     data_by_con{2,i} = ft_selectdata(cfg, data);
     data_by_con{2,i}.cfg.event = data_by_con{2,i}.cfg.previous.event;
     
 end
 
 
 % "excessive activity in foreperiod" rausschmeißen
dat = data_by_con{2,1};
% global threshold
th = 0.25*mean(cellfun(@(x) max(x(1,:)), dat.trial));

for i = 1:length(dat.trial)
    %index of first timepoint exceeding the threshold:
    idx = find(dat.trial{i}(1,:) >= th,1);
    if not(isempty(idx))
         htime(i) = dat.time{i}(idx);
    else
        htime(i) = nan;
    end
end

dat.trialinfo = [dat.trialinfo(:,1), htime.'];
%trialinfo now containing: trigger,time of response
%add this to events


