function [ out ] = ph1valid01_prepro( subjid )

ph1valid_setup;

if  nargin == 0
subjid = 'VP20';
end;

% find CNT file of subject 25
fname = dir(fullfile(emg_path, subjid, '*.bdf'));
fname = fname.name;
data_file = fullfile(emg_path, subjid, fname);



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
 %ft_databrowser(cfg, data);
 %ft_databrowser(cfg, data_AN_prep);

% split data into four conditions
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    

th = [];
 for i = 1:length(conds)
     con = conds{1,i};
     trg = conds{2,i};
     chani = conds{3,i};
     
     
     cfg = [];
     %cfg.channel = chan; not a good idea
     cfg.trials = find(data.trialinfo == trg);
     
     
     indices = find(data.trialinfo == trg);
     indices = indices(indices<=200);
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
     data.trialinfo(indices,2) = htime.';
     data.trialinfo(indices,3) = hind.';
     data.trialinfo(indices,4) = hind_tot.';
 end
 
 
 misses = find(isnan(data.trialinfo(:,2)));
 errors = find(data.trialinfo(:,2) <= 0);
 happies = find(data.trialinfo(:,1) == 52 | data.trialinfo(:,1) == 62);
 prepareds = find(data.trialinfo(:,1) == 51 | data.trialinfo(:,1) == 52);

 
 data.trialinfo(:,5) = false;
 data.trialinfo(:,6) = false;
 data.trialinfo(:,7) = false;
 data.trialinfo(:,8) = false;
 data.trialinfo(errors,5) = true;
 data.trialinfo(misses,6) = true;

 
 % clean response-Time-Variable
 data.trialinfo([errors; misses],2) = nan;
 data.trialinfo(prepareds,7) = true;
 data.trialinfo(happies,8) = true;
 
 %write to file
 mkdir(fullfile(emg_out_path, subjid));
 save(fullfile(emg_out_path, subjid, [subjid '_prepro.mat']), 'data');
 
 disp(['wrote ' subjid '_prepro.mat']);
 
end