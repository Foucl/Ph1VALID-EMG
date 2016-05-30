%% setup

% setup paths
script_path = 'O:/Mitarbeiter/Christopher/Analysis_ValidExp/EMG/Matlab/Ph1VALID-EMG/Kladde_VP25';
toolboxes_path = 'O:/Mitarbeiter/Christopher/Tools/Matlab-toolboxes';
data_path = 'O:\Mitarbeiter\Christopher\Data_ValidExp';
data_path_loc = 'C:\Users\DDMitarbeiter\Documents\Christopher\Data_ValidExp';
emg_path = fullfile(data_path_loc, 'EMG_raw');
presentation_path = fullfile(data_path, 'Presentation-logfiles');

% remove existing eeglab & fieldtrip installations from path
%P=regexp(matlabpath,';','split');
%P = P(cellfun(@isempty,regexp(P,'(eeglab)|(fieldtrip)')));
%new_path = cell2mat(strcat(P,';'));
%matlabpath(new_path);
restoredefaultpath;

% add my git clones of eeglab and fieldtrip to path
addpath(fullfile(toolboxes_path, 'fieldtrip'));
addpath(fullfile(toolboxes_path, 'fieldtrip', 'fileio')); %TODO parametrize that
addpath(fullfile(toolboxes_path, 'eeglab'));

% find CNT file of subject 25
fname = dir(fullfile(emg_path, 'VP25', '*.bdf'));
fname = fname.name;
data_file = fullfile(emg_path, 'VP25', fname);

%% loading in fieldtrip

% basic prepro: downsample, filter, rectify (?)
% get all Response Priming trials:

 cfg = [];                                   % create an empty variable called cfg
 cfg.trialdef.prestim = 1.9;                 % in seconds
 cfg.trialdef.poststim = 1.5;                  % in seconds
 cfg.trialdef.eventvalue = [51 52 62 61];
 cfg.trialdef.eventtype = 'STATUS';
 %cfg.trialdef.eventtype = 'gui';
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


