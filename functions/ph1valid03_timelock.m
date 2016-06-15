%% Timelock

SessionInfo = ph1valid_setup;
%subjid='VP44';

subjmfileDir = SessionInfo.subjmfileDir;

%prepro_file = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_class.mat']);

%if ~exist(prepro_file, 'file')
%    error([subjid ' not yet preprocessed, couldnt find ' prepro_file]);
%end;

%load(prepro_file);

conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2};
    
allSub_ANp=[];
allSub_ANup=[];
allSub_HAp=[];
allSub_HAup=[];
th = [];
fehler = [];
k = 1;
for i = 1:46
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end;
    arg = ['VP' b];
    try
        prepro_file = fullfile(SessionInfo.emgPreproDir, arg, [arg '_prepro_class.mat']);
        load(prepro_file);
        %for j = 1:length(conds)
            % con = conds{1,j};
             %trg = conds{2,j};
             %chani = conds{3,j};
             chan_AN = 1;
             trg_ANp = conds{2,1};
             trg_ANup = conds{2,2};
             indices_ANp = find(data.trialinfo(:,1) == trg_ANp & ~isnan(data.trialinfo(:,3)));
             indices_ANup = find(data.trialinfo(:,1) == trg_ANup & ~isnan(data.trialinfo(:,3)));
             
             chan_HA = 2;
             trg_HAp = conds{2,3};
             trg_HAup = conds{2,4};
             indices_HAp = find(data.trialinfo(:,1) == trg_HAp & ~isnan(data.trialinfo(:,3)));
             indices_HAup = find(data.trialinfo(:,1) == trg_HAup & ~isnan(data.trialinfo(:,3)));
             
             %indices = find(data.trialinfo(:,1) == trg & ~isnan(data.trialinfo(:,3)));
             %indices = indices(indices<=200);
             
             cfg = [];
             cfg.trials = indices_ANp;
             cfg.channels = chan_AN;
             allSub_ANp{i} = ft_timelockanalysis(cfg,data);
             cfg.trials = indices_ANup;
             allSub_ANup{i} = ft_timelockanalysis(cfg,data);
             
             cfg = [];
             cfg.baseline = [-0.1 0];
             cfg.channel = chan_AN;
             allSub_ANup{i} = ft_timelockbaseline(cfg,allSub_ANup{i});
             allSub_ANp{i} = ft_timelockbaseline(cfg,allSub_ANp{i});
             
             cfg = [];
             cfg.trials = indices_HAp;
             cfg.channels = chan_HA;
             allSub_HAp{i} = ft_timelockanalysis(cfg,data);
             
             cfg = [];
             cfg.trials = indices_HAup;
             cfg.channels = chan_HA;
             allSub_HAup{i} = ft_timelockanalysis(cfg,data); 
             
%              cfg = [];
%              cfg.trials = indices;
%              cfg.channels = chani;
%              timelock(i).(con) = ft_timelockanalysis(cfg, data);  
       % end
    catch ME
        disp(ME);
        fehler{k,1} = ['VP' b];
        fehler{k,2} = ME.message;
        k = k + 1;
    end;
end
disp(fehler);

%a = [timelock(:).AN_prep];

allSub_ANp = allSub_ANp(~cellfun('isempty',allSub_ANp));
allSub_ANup = allSub_ANup(~cellfun('isempty',allSub_ANup));
allSub_HAp = allSub_HAp(~cellfun('isempty',allSub_HAp));
allSub_HAup = allSub_HAup(~cellfun('isempty',allSub_HAup));

cfg = [];
cfg.channel   = 'Cor';
cfg.latency   = 'all';
cfg.parameter = 'avg';
[ga_anp] = ft_timelockgrandaverage(cfg, allSub_ANp{:});
[ga_anup] = ft_timelockgrandaverage(cfg, allSub_ANup{:});

cfg = [];
cfg.parameter = 'avg';
%cfg.channel = 1;
cfg.hotkeys = 'yes';
%cfg.baseline = 'yes';
cfg.xlim = [-0.1 2.5];
ft_singleplotER(cfg, ga_anp, ga_anup);

cfg = [];
cfg.channel   = 'Zyg';
cfg.latency   = 'all';
cfg.parameter = 'avg';
[ga_hap] = ft_timelockgrandaverage(cfg, allSub_HAp{:});
[ga_haup] = ft_timelockgrandaverage(cfg, allSub_HAup{:});

cfg = [];
cfg.parameter = 'avg';
%cfg.channel = 1;
%cfg.baseline = 'yes';
cfg.hotkeys = 'yes';
cfg.xlim = [-0.1 2.5];
ft_singleplotER(cfg, ga_hap, ga_haup);

