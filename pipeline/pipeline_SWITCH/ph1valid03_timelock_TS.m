function [ ga, fig ] = ph1valid03_timelock_TS (forceInd, forceGa)
%% Timelock

if nargin < 1
    forceInd = false;
    forceGa = false;
elseif nargin < 2
    forceGa = false;
end;


SessionInfo = ph1valid_setup;

[ ga, ~ ]  = aggregateTimelocks (SessionInfo, forceInd, forceGa);


cfg = [];
cfg.xlim = [-0.1 2.5];
cfg.interactive = 'no';
cfg.linestyle = {'-', '--', '-', '--'};
cfg.graphcolor = 'kkmm';
cfg.linewidth = 0.8;

inner_padding = [0.07, 0.06];
figure;
subplot_tight(2,2,1, inner_padding);
ft_singleplotER(cfg, ga.AN_rep_cor, ga.AN_swt_cor, ga.HA_rep_cor, ga.HA_swt_cor);
title('Cor');
subplot_tight(2,2,2, inner_padding);
ft_singleplotER(cfg, ga.HA_rep_zyg, ga.HA_swt_zyg, ga.AN_rep_zyg, ga.AN_swt_zyg);
title('Zyg');
subplot_tight(2,2,3, inner_padding);
ft_singleplotER(cfg, ga_RP.AN_prep_cor, ga_RP.AN_unprep_cor, ga_RP.HA_prep_cor, ga_RP.HA_unprep_cor);
title('Cor');
subplot_tight(2,2,4, inner_padding);
ft_singleplotER(cfg, ga_RP.AN_prep_zyg, ga_RP.AN_unprep_zyg, ga_RP.HA_prep_zyg, ga_RP.HA_unprep_zyg);
title('Zyg');
legend1 = legend({'anger valid', 'anger invalid', 'happiness valid', 'happiness valid'}, 'Location', 'NorthEast');

set(legend1,...
    'Position',[0.672619053366638 0.0861111285231143 0.266071422823838 0.165476185934884]);
tightfig;
 

fig = gcf;



function [ TlCond ] = calcTimelock (subjid, emgPreproDir, force)


 target_file = fullfile(emgPreproDir, subjid, [subjid '_timelock_ts.mat']);
 if exist(target_file,'file') && force == false
     %warning([subjid ': Timelock already calculated, not overwriting'])
     load(target_file);
     return
 end;

 prepro_file = fullfile(emgPreproDir, subjid, [subjid '_prepro_ts_class.mat']);
 load(prepro_file);

 conds = data.conds;
 
 conds = {[conds{1,1} '_cor'], [conds{1,1} '_zyg'], [conds{1,2} '_cor'], ...
     [conds{1,2} '_zyg'], [conds{1,3} '_zyg'], [conds{1,3} '_cor'], ...
     [conds{1,4} '_zyg'], [conds{1,4} '_cor'];
     conds{2,1} conds{2,1} conds{2,2} conds{2,2} conds{2,3} conds{2,3} ...
     conds{2,4} conds{2,4}; 1 2 1 2 2 1 2 1};
 
 for i = 1:size(conds,2)
     con = conds{1,i};
     trg = conds{2,i};
     chan = conds{3,i};
     indices = find(ismember(data.trialinfo(:,1), trg) & ~isnan(data.trialinfo(:,3)));

     cfg = [];
     cfg.trials = indices;
     cfg.channel = chan;
     TlCond.(con) = ft_timelockanalysis(cfg,data);
 end;

 save(fullfile(emgPreproDir, subjid, [subjid '_timelock_ts.mat']), 'TlCond');

 function [ ga, TlCond ] = aggregateTimelocks (SessionInfo, force, forceGA)

ga_file = fullfile(SessionInfo.outDir, 'tlga_ts.mat');
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
