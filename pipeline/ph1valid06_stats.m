function [ mfile_table ] = ph1valid06_stats( input_args )
%PH1VALID06_STATS Summary of this function goes here
%   Detailed explanation goes here

SessionInfo = ph1valid00_setup;


subjmfileDir = SessionInfo.subjmfileDir;

existingSubjmfiles = ls(subjmfileDir);
existingSubjmfiles = existingSubjmfiles(3:end,1:end-2);
%excl = ['VP03_subjinfo';'VP07_subjinfo';'VP08_subjinfo';'VP11_subjinfo';'VP14_subjinfo'];
%existingSubjmfiles = setdiff(existingSubjmfiles, excl, 'rows');

io.normalizeStructs(existingSubjmfiles)

for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_table = struct2table(sub);

%% some plotting
% h1 = histogram(mfile_table.AN_prep_meanRT);
% hold on
% h2 = histogram(mfile_table.AN_unprep_meanRT);
% 
% h1.Normalization = 'pdf';
% h1.BinWidth = 0.1;
% h2.Normalization = 'pdf';
% h2.BinWidth = 0.1;
% 
% pd = fitdist(mfile_table.AN_prep_meanRT,'Kernel', 'Width', 0.05);
% x_values = 0.1:0.01:1.2;
% y = pdf(pd,x_values);
% plot(x_values,y);


%% generate pretty, informative table
% TODO: get variance of each channel (using the ga object?)
% be smarter about variable collection:

% generate names of variables of interest programmatically

standard_vars = {'subjid', 'isExcluded_Rp', 'isExcluded_Ts'};
demo_vars = {'subjid', 'date', 'alter', 'geschlecht', 'psyc'};

T_demo = mfile_table(:, demo_vars);

em = {'AN', 'HA'};
valid = {'val', 'inval'};
exp = {'Rp', 'Ts'};
measures = {'meanRT', 'sdRT', 'nErrorTrials', 'nFpTrials', 'nOmissionTrials', ...
    'nHitTrials'};
nTrialVars = length(measures) * length(exp) * length(valid) * length(em);
m = 1;
trialVars = cell(1, nTrialVars);
for i = 1:length(em)
    for j = 1:length(valid)
        for k = 1:length(exp)
            for l = 1:length(measures)
                trialVars{m} = [em{i} '_' valid{j} '_' measures{l} '_' exp{k}];
                m = m + 1 ;
            end
        end
    end
end

T_behav = mfile_table(:,[standard_vars, trialVars]);

sign_measures ={'MeanMaxAmp', 'MeanMaxAmpTime', 'SdMaxAmp'};
nSignVars = length(sign_measures) * length(exp) * length(valid) * length(em);
m = 1;
signVars = cell(1, nSignVars);
for i = 1:length(em)
    for j = 1:length(valid)
        for k = 1:length(exp)
            for l = 1:length(sign_measures)
                signVars{m} = [em{i} '_' valid{j} '_' sign_measures{l} '_' exp{k}];
                m = m + 1 ;
            end
        end
    end
end

T_sign = mfile_table(:,[standard_vars, signVars]);

%% state & other self report measures from experimental run
% TODO: map state (mood, ruhig, erregt, wach, mued) to correct experiment
% TODO: get correct 'is_excluded_{experiment}' values during prepro

rp_gen_vars = {'nRpTrials', 'nErrors', 'nFP', 'nOmissions', 'nHits'};
ts_gen_vars = ['nTsTrials', cellfun(@(x) [x '_ts'], rp_gen_vars(2:end), 'Uniform', 0)];
conds_rp = {'AN_prep', 'AN_unprep', 'HA_prep', 'HA_unprep'};
conds_ts = {'AN_rep', 'AN_swt', 'HA_rep', 'HA_swt'};
con_vars = {'nFpTrials', 'nOmissionTrials', 'nHitTrials', 'meanRT', 'sdRT', 'propOm', 'propHit', 'propFP', ...
    'cleanMeanMaxAmp'};


rp_con_vars = cell(length(conds_ts), length(con_vars));
ts_con_vars = rp_con_vars;
for i = 1:length(conds_rp)
    for j = 1:length(con_vars)
        rp_con_vars{i, j} = [conds_rp{i} '_' con_vars{j}];
        ts_con_vars{i, j} = [conds_ts{i} '_' con_vars{j}];
    end;
end;
mfile_table.nTsTrials = mfile_table.nFP_ts + mfile_table.nErrors_ts + mfile_table.nOmissions_ts + mfile_table.nHits_ts;

interesting_vars = [standard_vars'; ts_gen_vars'; rp_gen_vars'; ts_con_vars(:); rp_con_vars(:)];
T = mfile_table(:, interesting_vars);
T.geschlecht = categorical(T.geschlecht, [1, 2], {'male', 'female'});
T.Properties.VariableNames{'geschlecht'} = 'sex';
T.Properties.VariableNames{'alter'} = 'age';
T.happy_letter = upper(T.happy_letter);
T.propErrors_RP = T.nErrors./T.nRpTrials;
T.propErrors_TS = T.nErrors_ts./T.nTsTrials;
T.propHits_RP = T.nHits./T.nRpTrials;
T.propHits_TS = T.nHits_ts./T.nTsTrials;

T_matthias = T(:,[1:3 5 end-3:end 30 32 66 68]);

openvar('T_matthias')

T_matthias_sortError = sortrows(T_matthias,{'propErrors_TS','propErrors_RP'},{'descend','descend'})

qual_vars = {'subjid', 'date', 'emg_data', 'nRpTrials', 'isExcluded', 'nErrors', 'propErrors', 'nFP', 'nOmissions', ...
    'AN_prep_meanRT', 'AN_unprep_meanRT', 'HA_prep_meanRT', 'HA_unprep_meanRT', 'AN_prep_mean_max_amp','AN_unprep_mean_max_amp', ...
    'HA_prep_mean_max_amp', 'HA_unprep_mean_max_amp'};
%T_qual = T(:, qual_vars);


%writetable(T, 'subjinfo.csv');

%grpstats(T,[], {'mean', 'sem'}, 'datavars',{'HA_meanRT', 'AN_meanRT', 'prep_meanRT', 'unprep_meanRT'})

valid = [mean(T.HA_prep_meanRT); mean(T.AN_prep_meanRT)];
invalid = [mean(T.HA_unprep_meanRT); mean(T.AN_unprep_meanRT)];
anRT = table(valid, invalid, 'RowNames', {'Happiness', 'Anger'});

%% construct anova-table:
% and be smart about it this time as well

for i = 1:length(conds_rp)
    for j = 1:length(con_vars)
        rp_con_vars{i, j} = [conds_rp{i} '_' con_vars{j}];
        ts_con_vars{i, j} = [conds_ts{i} '_' con_vars{j}];
    end;
end;

rt_vars = {'subjid', 'AN_prep_meanRT',  'AN_unprep_meanRT', 'HA_prep_meanRT', 'HA_unprep_meanRT'};
rt_vars_ts = {'subjid', 'AN_rep_meanRT',  'AN_swt_meanRT', 'HA_rep_meanRT', 'HA_swt_meanRT'};
T_RT = T(:,rt_vars);
T_RT_ts = T(:,rt_vars_ts);

hit_vars = {'subjid', 'AN_prep_propHit',  'AN_unprep_propHit', 'HA_prep_propHit', 'HA_unprep_propHit'};
hit_vars_ts = {'subjid', 'AN_rep_propHit',  'AN_swt_propHit', 'HA_rep_propHit', 'HA_swt_propHit'};
T_hit = T(:,hit_vars);
T_hit_ts = T(:,hit_vars_ts);

om_vars = {'subjid', 'AN_prep_propOm',  'AN_unprep_propOm', 'HA_prep_propOm', 'HA_unprep_propOm'};
om_vars_ts = {'subjid', 'AN_rep_propOm',  'AN_swt_propOm', 'HA_rep_propOm', 'HA_swt_propOm'};
T_om = T(:,om_vars);
T_om_ts = T(:,om_vars_ts);

fp_vars = {'subjid', 'AN_prep_propFP',  'AN_unprep_propFP', 'HA_prep_propFP', 'HA_unprep_propFP'};
fp_vars_ts = {'subjid', 'AN_rep_propFP',  'AN_swt_propFP', 'HA_rep_propFP', 'HA_swt_propFP'};
T_fp = T(:,fp_vars);
T_fp_ts = T(:,fp_vars_ts);

%% long
% T2 = stack(T_RT, rt_vars(2:end), 'NewDataVariableName','RT', 'IndexVariableName','Condition')
% a = T2.Condition;
% [b] = cellfun(@(x) strsplit(x, '_'), a, 'UniformOutput', false);
% for i = 1:length(b)
%     curcell = b{i};
%     if i == 1
%         em = curcell(1);
%         val = curcell(2);
%     else
%         em = [em; curcell(1)];
%         val = [val; curcell(2)];
%     end;
% end;
% 
% T2.Condition = [];
% T2.em = em;
% T2.val = val;

%% doch wide: funktionierender Code für RT
em = categorical({'AN'; 'AN'; 'HA'; 'HA'; });
val = categorical({'prep'; 'unprep'; 'prep'; 'unprep'});
val_ts = categorical({'rep'; 'swt'; 'rep'; 'swt'});
%val = val_ts;
factors = table(em,val_ts);
factors_rp = table(em, val);
rm_RT = fitrm(T_RT,'AN_prep_meanRT-HA_unprep_meanRT~1','WithinDesign',factors_rp); 
rm_hit = fitrm(T_hit, 'AN_prep_propHit-HA_unprep_propHit~1', 'WithinDesign', factors_rp);
rm_fp = fitrm(T_fp, 'AN_prep_propFP-HA_unprep_propFP~1', 'WithinDesign', factors_rp);
rm_om = fitrm(T_om, 'AN_prep_propOm-HA_unprep_propOm~1', 'WithinDesign', factors_rp);

rm_RT_ts = fitrm(T_RT_ts,'AN_rep_meanRT-HA_swt_meanRT~1','WithinDesign',factors); 
rm_hit_ts = fitrm(T_hit_ts, 'AN_rep_propHit-HA_swt_propHit~1', 'WithinDesign', factors);
rm_fp_ts = fitrm(T_fp_ts, 'AN_rep_propFP-HA_swt_propFP~1', 'WithinDesign', factors);
rm_om_ts = fitrm(T_om_ts, 'AN_rep_propOm-HA_swt_propOm~1', 'WithinDesign', factors);

myanova = ranova(rm_RT, 'WithinModel','em*val');

%plotprofile(rm_fp, 'val', 'Group', 'em');

figure
subplot(2,2,1)       % add first plot in 2 x 1 grid
plotprofile(rm_RT_ts, 'val', 'Group', 'em');
title('Reaction Times')

subplot(2,2,2)       % add second plot in 2 x 1 grid
plotprofile(rm_hit_ts, 'val', 'Group', 'em');       % plot using + markers
title('Proportion Hits')

subplot(2,2,3)       % add second plot in 2 x 1 grid
plotprofile(rm_fp_ts, 'val', 'Group', 'em');       % plot using + markers
title('Proportion False Positives')

subplot(2,2,4)       % add second plot in 2 x 1 grid
plotprofile(rm_om_ts, 'val', 'Group', 'em');       % plot using + markers
title('Proportion Omissions')

figure
subplot(2,2,1)       % add first plot in 2 x 1 grid
plotprofile(rm_RT_ts, 'val_ts', 'Group', 'em');
title('Reaction Times')

subplot(2,2,2)       % add second plot in 2 x 1 grid
plotprofile(rm_hit_ts, 'val_ts', 'Group', 'em');       % plot using + markers
title('Proportion Hits')

subplot(2,2,3)       % add second plot in 2 x 1 grid
plotprofile(rm_fp_ts, 'val_ts', 'Group', 'em');       % plot using + markers
title('Proportion False Positives')

subplot(2,2,4)       % add second plot in 2 x 1 grid
plotprofile(rm_om, 'val_ts', 'Group', 'em');       % plot using + markers
title('Proportion Omissions')


% 
% %weiter wie gewohnt

