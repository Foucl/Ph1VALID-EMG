function [ ga ] = aggregateTimelocks (experiment, ~, force, forceGA)

SessionInfo = ph1valid00_setup;
SessionInfo.outDir = fullfile(SessionInfo.dataDir, 'processed', 'EMG_GrandAverages');

em = {'AN', 'HA'};
valid = {'val', 'inval'};
musc = {'cor', 'zyg'};
l = 1;
for i = 1:length(em)
    for j = 1: length(valid)
        for k = 1: length(musc)
            baseCons{l} = [em{i} '_' valid{j} '_' musc{k}];
            l = l +1;
        end;
    end;
end;

c = cell(8,1);
TlCondTemplate = struct('Rp', cell2struct(c, baseCons), 'Ts', cell2struct(c, baseCons));
conds = prepro.defineConditions('VP46');

exps = fieldnames(conds);
tmpl = [];
for i = 1:length(exps)
    curcon = conds.(exps{i});
    for j = 1:length(curcon)
        tmpl.(exps{i}).([curcon{1,j} '_cor']) = [];
        tmpl.(exps{i}).([curcon{1,j} '_zyg']) = [];
    end
end;
TlCondTemplate = tmpl;



if strcmpi(experiment, 'all')
    exp = {'Rp', 'Ts', 'Ts_fine'};
else
    exp{1} = experiment;
end;

for k = 1:length(exp)
    ga_file = fullfile(SessionInfo.outDir, ['tlga_' exp{k} '.mat']);
    if exist(ga_file,'file') && ~forceGA
        gaCur = load(ga_file);
        ga.(exp{k}) = gaCur.ga.(exp{k});
        %TlCond = nan;
        continue;
    end;
    
    %% read individual timelocks
clear TlCond;    
TlCond.(exp{k}) = TlCondTemplate.(exp{k});
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
            TlCond(i) = ph1valid04_timelockSubject (exp{k}, arg, force);
         catch ME
             disp(ME);
             fehler{j} = sprintf('%s: %s', arg, ME.message);
             j = j + 1;
         end;
    end
    toc
    fehler = fehler(~cellfun('isempty',fehler));
    disp(fehler);
    TlCondCur = [TlCond.(exp{k})];
    empty_elems = arrayfun(@(s) all(structfun(@isempty,s)), TlCondCur);
    TlCond(empty_elems) = [];
    TlCondCur(empty_elems) = [];
    
    %% calculate grand averaged timelock for each condition
    conds = fieldnames(TlCondCur);
    for i = 1:length(conds)
        con = conds{i};
        %TlCondCur = TlCond.(exp{k});
        tl = {TlCondCur(:).(con)};
        cfg = [];
        cfg.parameter = 'avg';
        ga.(exp{k}).(con) = ft_timelockgrandaverage(cfg, tl{:});
    end;
    %TODO: is skipped because of warning concerning matlab 7.3
    save(ga_file, 'ga');
end;


