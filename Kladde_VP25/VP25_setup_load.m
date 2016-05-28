%% setup

% setup paths
script_path = 'O:/Mitarbeiter/Christopher/Analysis_ValidExp/EMG/Matlab/Ph1VALID-EMG/Kladde_VP25';
toolboxes_path = 'O:/Mitarbeiter/Christopher/Tools/Matlab-toolboxes';
data_path = 'O:\Mitarbeiter\Christopher\Data_ValidExp';
emg_path = fullfile(data_path, 'EMG_raw');
presentation_path = fullfile(data_path, 'Presentation-logfiles');

% remove existing eeglab & fieldtrip installations from path
P=regexp(matlabpath,';','split');
P = P(cellfun(@isempty,regexp(P,'(eeglab)|(fieldtrip)')));
new_path = cell2mat(strcat(P,';'));
matlabpath(new_path);

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
 cfg.trialdef.prestim = 0.5;                 % in seconds
 cfg.trialdef.poststim = 3.5;                  % in seconds
 cfg.trialdef.eventvalue = [51 52 62 61];
 cfg.trialdef.eventtype = 'STATUS';
 cfg.trialfun = 'ft_trialfun_general';
 cfg.dataset = data_file;
 cfg.headerfile = data_file;
 cfg = ft_definetrial(cfg);
% baseline
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.5 0];
% Fitering options
cfg.hpfilter        = 'yes';
cfg.hpfreq          = 10;
% Re-referencing options - see explanation below
cfg.reref = 'no';
bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
bipolar.labelnew  = {'Cor', 'Zyg'};
bipolar.tra       = [
      +1 -1  0  0
       0  0 +1 -1
    ];
cfg.montage = bipolar;
data = ft_preprocessing(cfg);

% data_orig = data; %save the original data for later use
cfg            = [];
cfg.resamplefs = 768;
cfg.detrend    = 'no';
cfg.sampleindex = 'yes';
data_ds           = ft_resampledata(cfg, data);

% http://mailman.science.ru.nl/pipermail/fieldtrip/2015-March/009054.html
% http://mailman.science.ru.nl/pipermail/fieldtrip/2014-January/007427.html


data = data_orig;
data_ds = data;
 
 cfg = [];
 %cfg.dataset = data;
 ft_databrowser(cfg, data);