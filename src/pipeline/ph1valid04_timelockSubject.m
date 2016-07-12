function [ TlCond ] = ph1valid04_timelockSubject (experiment, subjid, force)
%% runs timelock on subjid; geturns TlCond structure, containing the experiment sub structures, 
% containing the timelock for each condition

SessionInfo = ph1valid00_setup;

emgPreproDir = SessionInfo.emgPreproDir;



eval([subjid '_subjinfo']);
conditions = prepro.defineConditions(subjinfo);

if strcmpi(experiment, 'all')
    exp = {'Rp', 'Ts', 'Ts_fine'};
else
    exp{1} = experiment;
end;



for j = 1:length(exp)
    
    target_file = fullfile(emgPreproDir, subjid, [subjid '_timelock_' exp{j} '.mat']);
    if exist(target_file,'file') && force == false
        %warning([subjid ': Timelock already calculated, not overwriting'])
        load(target_file);
        TlCond.(exp{j}) = TlCondCur;
        continue
    end;
    
    
    prepro_file = fullfile(emgPreproDir, subjid, [subjid '_class_' exp{j} '.mat']);
    load(prepro_file);
    %conds = [];
    conds = conditions.(exp{j});
    
    if ~strcmpi(exp{j}, 'Ts_fine')
    conds = {[conds{1,1} '_cor'], [conds{1,1} '_zyg'], [conds{1,2} '_cor'], ...
        [conds{1,2} '_zyg'], [conds{1,3} '_zyg'], [conds{1,3} '_cor'], ...
        [conds{1,4} '_zyg'], [conds{1,4} '_cor'];
        conds{2,1} conds{2,1} conds{2,2} conds{2,2} conds{2,3} conds{2,3} ...
        conds{2,4} conds{2,4}; 1 2 1 2 2 1 2 1};
    else
        % DONE: smart generation of conditions for Ts_fine (via loop), in
        % order to replace the option above
        % TODO: check if var-generation works for all experiments
        conds_orig = conds;
        conds = cell(3,length(conds_orig) * 2);
        for i = 1:length(conds_orig)
            indB = i * 2;
            indA = i * 2 - 1;
            conds{1,indA} = [conds_orig{1,i} '_cor'];
            conds{1,indB} = [conds_orig{1,i} '_zyg'];
            [conds{2, indA:indB}] = deal(conds_orig{2,i});
            conds{3, indA} = 1;
            conds{3, indB} = 2;
        end;
    end;
    
    for i = 1:size(conds,2)
        con = conds{1,i};
        trg = conds{2,i};
        chan = conds{3,i};
        indices = find(ismember(data.trialinfo(:,1), trg) & ~isnan(data.trialinfo(:,3)));
        
        cfg = [];
        cfg.trials = indices;
        cfg.channel = chan;
        tl = ft_timelockanalysis(cfg,data);
        TlCond.(exp{j}).(con) = tl;
        variable = [con 'MeanVariance_' exp{j}];
        Info.(variable) = mean(tl.var);
    end;
    TlCondCur = TlCond.(exp{j});
    save(fullfile(emgPreproDir, subjid, [subjid '_timelock_' exp{j} '.mat']), 'TlCondCur');
end;
io.writeToSubjmfile(Info, subjid);