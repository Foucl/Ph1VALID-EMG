function [ ga ] = ph1valid03_timelock
%% Timelock

SessionInfo = ph1valid_setup;
%subjid='VP44';

%subjmfileDir = SessionInfo.subjmfileDir;

%prepro_file = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_class.mat']);

%if ~exist(prepro_file, 'file')
%    error([subjid ' not yet preprocessed, couldnt find ' prepro_file]);
%end;

%% generate timelocks for every subject

% function:

%[ TlCond ] = calcTimelock ('VP16', SessionInfo.emgPreproDir, false);

%excl = ['VP03_subjinfo';'VP07_subjinfo';'VP08_subjinfo';'VP11_subjinfo';'VP14_subjinfo'];

[ ga, ~ ]  = aggregateTimelocks (SessionInfo, false, false);


cfg = [];
cfg.xlim = [-0.1 2.5];
cfg.interactive = 'no';
cfg.linestyle = {'-', '--', '-', '--'};
cfg.graphcolor = 'kkmm';
cfg.linewidth = 0.8;

figure
subplot(1,2,1, 'align')
ft_singleplotER(cfg, ga.AN_prep_cor, ga.AN_unprep_cor, ga.HA_prep_cor, ga.HA_unprep_cor);
title('Cor');
subplot(1,2,2, 'align')
ft_singleplotER(cfg, ga.HA_prep_zyg, ga.HA_unprep_zyg, ga.AN_prep_zyg, ga.AN_unprep_zyg);
title('Zyg');
legend({'anger prepared', 'anger unprepared', 'happiness prepared', 'happiness unprepared'}, 'Location', 'NorthEastOutside');



function [ TlCond ] = calcTimelock (subjid, emgPreproDir, force)

conds = {'AN_prep_cor' 'AN_prep_zyg' 'AN_unprep_cor' 'AN_unprep_zyg'...
    'HA_prep_zyg' 'HA_prep_cor' 'HA_unprep_zyg' 'HA_unprep_cor';
        51 51 61 61 52 52 62 62;
        1 2 1 2 2 1 2 1};
 
 target_file = fullfile(emgPreproDir, subjid, [subjid '_timelock.mat']);
 if exist(target_file,'file') && force == false
     %warning([subjid ': Timelock already calculated, not overwriting'])
     load(target_file);
     return
 end;
    
 prepro_file = fullfile(emgPreproDir, subjid, [subjid '_prepro_class.mat']);
 load(prepro_file);
    
 for i = 1:size(conds,2)
     con = conds{1,i};
     trg = conds{2,i};
     chan = conds{3,i};
     indices = find(data.trialinfo(:,1) == trg & ~isnan(data.trialinfo(:,3)));
     
     cfg = [];
     cfg.trials = indices;
     cfg.channel = chan;
     TlCond.(con) = ft_timelockanalysis(cfg,data);
 end;
 
 save(fullfile(emgPreproDir, subjid, [subjid '_timelock.mat']), 'TlCond');
 
 function [ ga, TlCond ] = aggregateTimelocks (SessionInfo, force, forceGA)

ga_file = fullfile(SessionInfo.outDir, 'tlga.mat');
if exist(ga_file,'file') && ~forceGA
    load(ga_file, 'ga');
    TlCond = nan;
    return;
end;

%% read individual timelocks
fehler = cell(46,1);
j = 1;
tic;
for i = 1:46
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end;
    arg = ['VP' b];
    try
        TlCond(i) = calcTimelock (arg, SessionInfo.emgPreproDir, force);      
    catch ME
        disp(ME);
        fehler{j} = sprintf('%s: %s', arg, ME.message);
        j = j + 1;
    end;
end
toc
fehler = fehler(~cellfun('isempty',fehler));
disp(fehler);
empty_elems = arrayfun(@(s) all(structfun(@isempty,s)), TlCond);
TlCond(empty_elems) = [];

%% calculate grand averaged timelock for each condition
conds = fieldnames(TlCond);
for i = 1:length(conds)
    con = conds{i};
    tl = {TlCond(:).(con)};
    cfg = [];
    cfg.parameter = 'avg';
    ga.(con) = ft_timelockgrandaverage(cfg, tl{:});
end;

save(ga_file, 'ga');