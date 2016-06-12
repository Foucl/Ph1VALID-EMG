function [ data ] = ph1valid01_prepro( subjid )

ph1valid_setup;

if  nargin == 0
    subjid = 'VP23';
end;

% find CNT file of subject 25
fname = dir(fullfile(emg_path, subjid, '*.bdf'));
fname = fname.name;
data_file = fullfile(emg_path, subjid, fname);

% basic prepro: downsample, filter, rectify (?)
% get all Response Priming trials:

 cfg = [];                                   % create an empty variable called cfg
 cfg.trialdef.prestim = 2;                 % in seconds
 cfg.trialdef.poststim = 2.5;                  % in seconds
 cfg.trialdef.eventvalue = [51 52 62 61];
 cfg.trialdef.eventtype = 'STATUS';

 cfg.trialfun = 'ft_trialfun_general';
 cfg.dataset = data_file;
 cfg.headerfile = data_file;
 cfg = ft_definetrial(cfg);
 trl = cfg.trl;
% baseline correction
cfg.demean          = 'yes';
cfg.baselinewindow  = [-2 -1.8];
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

%rectify
data.trial = cellfun(@abs,data.trial, 'UniformOutput', false);

%resample, but keep sampleinfo (tricky)

si_old = data.sampleinfo;
ev_old = data.cfg.event;

 rs_fsample_pre = 1024;
 rs_fsample_post = 512;
rs_step = rs_fsample_pre/rs_fsample_post;
%data_old = data;
cfg            = [];
cfg.resamplefs = rs_fsample_post;
cfg.detrend    = 'no';
cfg.sampleindex = 'yes';
cfg.feedback = 'text';
%data           = ft_resampledata(cfg, data);

%for i = 3:length(ev_old)
 %   ev_old(i).sample = floor(ev_old(i).sample./rs_step);
%end

%data.cfg.event = ev_old;

%data.smpl = floor(si_old./rs_step);
%data.smplold = si_old;
%if data.smpl(1,1) == 0
  %data.smpl(1,1) = 1;
%end 

% http://mailman.science.ru.nl/pipermail/fieldtrip/2015-March/009054.html
% http://mailman.science.ru.nl/pipermail/fieldtrip/2014-January/007427.html

 
 cfg = [];
 %cfg.dataset = data;
 %cfg.channel = 'Zyg';
 cfg.continuous = 'no';
 cfg.viewmode = 'vertical';
 cfg.ylim = [-5 150];
 cfg.selectmode = 'marktroughevent';
% ft_databrowser(cfg, data);
 %ft_databrowser(cfg, data_AN_prep);

% split data into four conditions
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
%find thresholds
th = [];
for i = 1:length(conds)
    chani = conds{3,i};
    trg = conds{2,i};
    indices = find(data.trialinfo == trg);
    indices = indices(indices<=200);
    curdat = data.trial(indices);
    th(i) = 0.25*mean(cellfun(@(x) max(x(chani,:)), curdat));
end

%classify trials
 for i = 1:length(conds)
     con = conds{1,i};
     trg = conds{2,i};
     chani = conds{3,i};
     if chani == 1
         chani_o = 2;
     else
         chani_o = 1;
     end
          
     
     switch i
        case 1
            thc = th(3);
        case 2
            thc = th(4);
        case 3
            thc = th(1);
        case 4
            thc = th(2);
     end
          
     indices = find(data.trialinfo == trg);
     indices = indices(indices<=200);
     curdat = data.trial(indices);
     curtime = data.time(indices);
     cursample = data.sampleinfo(indices);
     curtriali = data.trialinfo(indices);
     
     htime=[];
     hind=[];
     hind_tot=[];
     htype=[]; %0: hit; 1: error, 2: ommission, 3: false positive
     for j = 1:length(curdat)
         zero = find(curtime{j}>=-0.3,1);
         idx = find(curdat{j}(chani,:) >=th(i),1); %indices of 'hits': => threshold in correct channel
         idx_wrong = find(curdat{j}(chani_o,:) >=thc,1); %indices of hits-in-wrong-channel: wrong emotions shown
         if i == 3 && (j == 3 || j == 5 || j == 9 || j == 10)
             disp(['condition: ' con]);
             disp(['trial = ' int2str(indices(j))]);
             disp(['idx = ' int2str(idx)]);
             disp(['idx_wrong = ' int2str(idx_wrong)]);
             disp(['time of idx = ' int2str(curtime{j}(idx))]);
             disp(['time of idx_wrong = ' int2str(curtime{j}(idx_wrong))]);
             %disp(['false-hit in trial ' int2str(j) ': ' int2str(idx_wrong) ' of condition ' con ' with th = ' int2str(thc) ' in channel ' int2str(chani_o)]);
             %disp(['right-hit in trial ' int2str(j) ': ' int2str(idx) ' of condition ' con ' with th = ' int2str(th(i)) ' in channel ' int2str(chani)]);
         end
         if isempty(idx) %empty string: no activity above threshold in correct channel - possible FP
             if isempty(idx_wrong) %ommission
                 htime(j)= nan;
                 hind(j) = nan;
                 hind_tot(j)= nan;
                 htype(j) = 2;
             elseif curtime{j}(idx_wrong) < 0 %error (activity in wrong channel too early -> failure to inhibit)                
                 htime(j) = nan;
                 hind(j) = nan;
                 hind_tot(j) = nan;
                 if curtime{j}(idx_wrong) <-0.3
                     htype(j) = 2;
                 else
                     htype(j) = 1;
                 end
                 
             else %idx_wrong > 0!! False Positive!
                 htime(j)= nan;
                 hind(j) = nan;
                 hind_tot(j)= nan;
                 htype(j) = 3;
             end
             
         elseif curtime{j}(idx) > 0
            htime(j) = curtime{i}(idx);
            hind(j) = idx;
            hind_tot(j) = cursample(j,1) + hind(j);
            htype(j) = 0;
         elseif curtime{j}(idx) <= 0 %error (activity too early)
            htime(j) = nan;
            hind(j) = nan;
            hind_tot(j) = nan;
            if curtime{j}(idx) <-0.3
                     htype(j) = 2;
                 else
                     htype(j) = 1;
                 end
         
         end
         
     end
     %data.trialinfo(indices) = [data.trialinfo(indices) htime.' hind.' hind_tot.'];
     data.trialinfo(indices,2) = htime.';
     data.trialinfo(indices,3) = hind.';
     data.trialinfo(indices,4) = hind_tot.';
     data.trialinfo(indices,5) = htype.';
     
 end
 
% data.trialinfo:
%   1: triggercode AN_prep: 51, AN_unprep: 61, HA_prep: 52, HA_unprep 62
%   2: trialtime in seconds for correct hit (NaN for error, FP and
%   ommission)
%   3: trial-index (sample point) of correct hit (NaN otherwise)
%   4: 'global'/original samplepoint of correct hit (NaN otherwise)
%   5: trial-category: 0: hit, 1: error, 2: ommission, 3: FP
 
 %write to file
 %openvar('data.trialinfo');
 mkdir(fullfile(emg_out_path, subjid));
 save(fullfile(emg_out_path, subjid, [subjid '_prepro.mat']), 'data');
 
 disp(['wrote ' subjid '_prepro.mat']);
 disp(['nr of errors in ha_prep: ' int2str(length(find(data.trialinfo(:,5)==1 & data.trialinfo(:,1) == 52).'))]);
 disp(['offending trials: ' int2str((find(data.trialinfo(:,5)==1 & data.trialinfo(:,1) == 52).'))]);
% data.cfg.origfs = [];
 %cfg = [];
 %cfg.channel='sampleindex';
%ft_databrowser(cfg, data);
 
end

