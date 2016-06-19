function [ mfile_table ] = ph1valid_aggregate_mfiles( input_args )
%PH1VALID_AGGREGATE_MFILES Summary of this function goes here
%   Detailed explanation goes here
global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

subjmfileDir = SessionInfo.subjmfileDir;

existingSubjmfiles = ls(subjmfileDir);
existingSubjmfiles = existingSubjmfiles(3:end,1:end-2);
excl = ['VP03_subjinfo';'VP07_subjinfo';'VP08_subjinfo';'VP11_subjinfo';'VP14_subjinfo'];
%existingSubjmfiles = setdiff(existingSubjmfiles, excl, 'rows');

normalizeStructs(existingSubjmfiles)

for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_table = struct2table(sub);

%% generate pretty, informative table
% be smarter about variable collection:

standard_vars = {'subjid', 'alter', 'geschlecht', 'date', 'emg_data', 'isExcluded', 'happy_letter'};
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

interesting_vars = [standard_vars'; ts_gen_vars'; rp_gen_vars'; ts_con_vars(:); rp_con_vars(:)];
T = mfile_table(:, interesting_vars);
T.geschlecht = categorical(T.geschlecht, [1, 2], {'male', 'female'});
T.Properties.VariableNames{'geschlecht'} = 'sex';
T.Properties.VariableNames{'alter'} = 'age';
T.happy_letter = upper(T.happy_letter);
T.propErrors_RP = T.nErrors/T.nRpTrials;
T.propErrors_TS = T.nErrors_ts/T.nTsTrials;

qual_vars = {'subjid', 'date', 'emg_data', 'nRpTrials', 'isExcluded', 'nErrors', 'propErrors', 'nFP', 'nOmissions', ...
    'AN_prep_meanRT', 'AN_unprep_meanRT', 'HA_prep_meanRT', 'HA_unprep_meanRT', 'AN_prep_mean_max_amp','AN_unprep_mean_max_amp', ...
    'HA_prep_mean_max_amp', 'HA_unprep_mean_max_amp'};
T_qual = T(:, qual_vars);


%writetable(T, 'subjinfo.csv');

grpstats(T,[], {'mean', 'sem'}, 'datavars',{'HA_meanRT', 'AN_meanRT', 'prep_meanRT', 'unprep_meanRT'})

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
T_RT = T(:,rt_vars);

hit_vars = {'subjid', 'AN_prep_propHit',  'AN_unprep_propHit', 'HA_prep_propHit', 'HA_unprep_propHit'};
T_hit = T(:,hit_vars);

om_vars = {'subjid', 'AN_prep_propOm',  'AN_unprep_propOm', 'HA_prep_propOm', 'HA_unprep_propOm'};
T_om = T(:,om_vars);

fp_vars = {'subjid', 'AN_prep_propFP',  'AN_unprep_propFP', 'HA_prep_propFP', 'HA_unprep_propFP'};
T_fp = T(:,fp_vars);

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
factors = table(em,val);
rm_RT = fitrm(T_RT,'AN_prep_meanRT-HA_unprep_meanRT~1','WithinDesign',factors); 
rm_hit = fitrm(T_hit, 'AN_prep_propHit-HA_unprep_propHit~1', 'WithinDesign', factors);
rm_fp = fitrm(T_fp, 'AN_prep_propFP-HA_unprep_propFP~1', 'WithinDesign', factors);
rm_om = fitrm(T_om, 'AN_prep_propOm-HA_unprep_propOm~1', 'WithinDesign', factors);

myanova = ranova(rm_RT, 'WithinModel','em*val');

%plotprofile(rm_fp, 'val', 'Group', 'em');

figure
subplot(2,2,1)       % add first plot in 2 x 1 grid
plotprofile(rm_RT, 'val', 'Group', 'em');
title('Reaction Times')

subplot(2,2,2)       % add second plot in 2 x 1 grid
plotprofile(rm_hit, 'val', 'Group', 'em');       % plot using + markers
title('Proportion Hits')

subplot(2,2,3)       % add second plot in 2 x 1 grid
plotprofile(rm_fp, 'val', 'Group', 'em');       % plot using + markers
title('Proportion False Positives')

subplot(2,2,4)       % add second plot in 2 x 1 grid
plotprofile(rm_om, 'val', 'Group', 'em');       % plot using + markers
title('Proportion Omissions')

function normalizeStructs(existingSubjmfiles)


subfields = cell(0,1);
for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
     % concatenate
    subfields = [subfields; fieldnames(subjinfo)];
end;
% 
% % find all unique fields
allfields = unique(subfields);
% 
% % do another loop and compare fieldnames with allfields, and create array of structs
for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
     % concatenate
    missingFields = setdiff(allfields, fieldnames(subjinfo));
     for j = 1:length(missingFields)
          subjinfo.(missingFields{j}) = nan;
     end;
     ph1valid_writeToSubjmfile(subjinfo, subjinfo.subjid);
end;
% 
% %weiter wie gewohnt