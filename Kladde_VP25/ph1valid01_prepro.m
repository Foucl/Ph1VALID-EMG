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

data.trial = cellfun(@abs,data.trial, 'UniformOutput', false);

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
 cfg.channel = 'Zyg';
 cfg.continuous = 'no';
 cfg.viewmode = 'vertical';
 cfg.ylim = [-5 150];
 cfg.selectmode = 'marktroughevent';
 ft_databrowser(cfg, dat);
 %ft_databrowser(cfg, data_AN_prep);

% split data into four conditions
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
data_by_con = cell(2,4);


th = [];
 for i = 1:length(conds)
     con = conds{1,i};
     trg = conds{2,i};
     chani = conds{3,i};
     data_by_con{1,i} = con;
     
     cfg = [];
     %cfg.channel = chan; not a good idea
     cfg.trials = find(data.trialinfo == trg);
     data_by_con{2,i} = ft_selectdata(cfg, data);
     data_by_con{2,i}.cfg.event = data_by_con{2,i}.cfg.previous.event;  
     
     indices = find(data.trialinfo == trg);
     curdat = data.trial(indices);
     curtime = data.time(indices);
     cursample = data.sampleinfo(indices);
     curtriali = data.trialinfo(indices);
     
     th(i) = 0.25*mean(cellfun(@(x) max(x(chani,:)), curdat));
     
     htime=[];
     hind=[];
     hind_tot=[];
     for j = 1:length(curdat)
         idx = find(curdat{j}(chani,:) >=th(i),1);
         
        if not(isempty(idx))
            htime(j) = curtime{i}(idx);
            hind(j) = idx;
            hind_tot(j) = cursample(j,1) + hind(j);
        else
            htime(j) = nan;
            hind(j) = nan;
            hind_tot(j) = nan;
        end
     end
     %data.trialinfo(indices) = [data.trialinfo(indices) htime.' hind.' hind_tot.'];
     % idee: erst drei weitere trialinfo-spalten anlegen (und mit nan oder
     % 0 füllen), dann an den richtigen stellen ersetzen?
 end
 
 dat = data_by_con{2,4};
 
 
 % "excessive activity in foreperiod" rausschmeißen
channel = 2;
% global threshold
thx = 0.25*mean(cellfun(@(x) max(x(channel,:)), dat.trial))


htime=[];
hind=[];
hind_tot=[];
for i = 1:length(dat.trial)
    %index of first timepoint exceeding the threshold:
    idx = find(dat.trial{i}(channel,:) >= thx,1);
    if not(isempty(idx))
         htime(i) = dat.time{i}(idx);
         hind(i) = idx;
         hind_tot(i) = dat.sampleinfo(i,1) + hind(i);
    else
        htime(i) = nan;
        hind(i) = nan;
        hind_tot(i) = nan;
    end
end

dat.trialinfo = [dat.trialinfo(:,1) htime.' hind.' hind_tot.'];
%trialinfo now containing: trigger,time of response
%add this to events


