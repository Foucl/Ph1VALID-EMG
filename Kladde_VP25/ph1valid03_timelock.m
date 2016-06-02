%% Timelock

ph1valid_setup;
subjid='VP09';

prepro_file = fullfile(emg_out_path, subjid, [subjid '_prepro.mat']);

if ~exist(prepro_file, 'file')
    error([subjid ' not yet preprocessed, couldnt find ' prepro_file]);
end;

load(prepro_file);

conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
th = [];
 for i = 1:length(conds)
     con = conds{1,i};
     trg = conds{2,i};
     chani = conds{3,i};
          
     indices = find(data.trialinfo(:,1) == trg & ~isnan(data.trialinfo(:,2)));
     indices = indices(indices<=200);
     curdat = data.trial(indices);
     curtime = data.time(indices);
     cursample = data.sampleinfo(indices);
     curtriali = data.trialinfo(indices);
     
     cfg = [];
     cfg.trials = indices;
     cfg.channels = chani;
     timelock(i) = ft_timelockanalysis(cfg, data);
     
 end
 


cfg = [];
%cfg.layout = 'mpi_customized_acticap64.mat';
cfg.parameter = 'avg';
cfg.channel = 1;
cfg.hotkeys = 'yes';
ft_singleplotER(cfg, timelock(1), timelock(2));
cfg = [];
%cfg.layout = 'mpi_customized_acticap64.mat';
cfg.parameter = 'avg';
cfg.channel = 2;
cfg.interactive = 'no';
cfg.hotkeys = 'yes';
ft_singleplotER(cfg, timelock(3), timelock(4));
