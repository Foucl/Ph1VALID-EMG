function [ ga, fig ] = ph1valid03_timelock (forceInd, forceGa)
%% Timelock

if nargin < 1
    forceInd = false;
    forceGa = false;
elseif nargin < 2
    forceGa = false;
end;


SessionInfo = ph1valid_setup;

[ ga, ~ ]  = aggregateTimelocks (SessionInfo, forceInd, forceGa);

global ft_default
ft_default.showcallinfo = 'no';

cfg = [];
cfg.xlim = [-0.1 2.5];
cfg.interactive = 'no';
cfg.linestyle = {'-', '--', '-', '--'};
cfg.graphcolor = 'kkmm';
cfg.linewidth = 0.8;

figure;
subplot(1,2,1, 'align');
ft_singleplotER(cfg, ga.AN_prep_cor, ga.AN_unprep_cor, ga.HA_prep_cor, ga.HA_unprep_cor);
title('Cor');
subplot(1,2,2, 'align');
ft_singleplotER(cfg, ga.HA_prep_zyg, ga.HA_unprep_zyg, ga.AN_prep_zyg, ga.AN_unprep_zyg);
legend({'anger prepared', 'anger unprepared', 'happiness prepared', 'happiness unprepared'}, 'Location', 'NorthEast');
title('Zyg');


fig = gcf;



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
