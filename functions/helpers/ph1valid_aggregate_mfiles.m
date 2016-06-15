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

normalizeStructs(existingSubjmfiles)

for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_table = struct2table(sub);

%% generate pretty, informative table
interesting_vars = {'subjid', 'date', 'emg_data', 'nRpTrials', 'isExcluded', 'first_block', 'happy_letter', 'alter', 'geschlecht', 'nErrors', ...
    'AN_prep_nFpTrials', 'AN_prep_nOmissionTrials', 'AN_prep_nHitTrials', 'AN_unprep_nFpTrials', ...
    'AN_unprep_nOmissionTrials', 'AN_unprep_nHitTrials', 'HA_prep_nFpTrials', 'HA_prep_nOmissionTrials', ...
    'HA_prep_nHitTrials', 'HA_unprep_nFpTrials', 'HA_unprep_nOmissionTrials', 'HA_unprep_nHitTrials', ...
    'AN_prep_meanRT', 'AN_prep_sdRT', 'AN_unprep_meanRT', 'AN_unprep_sdRT', 'HA_prep_meanRT', ...
    'HA_prep_sdRT', 'HA_unprep_meanRT', 'HA_unprep_sdRT', 'AN_meanRT', 'AN_sdRT', 'HA_meanRT', 'HA_sdRT', ...
    'prep_meanRT', 'prep_sdRT', 'unprep_meanRT', 'unprep_sdRT', 'AN_prep_propHit',  'AN_unprep_propHit',...
    'HA_prep_propHit', 'HA_unprep_propHit', 'AN_prep_propOm',  'AN_unprep_propOm',...
    'HA_prep_propOm', 'HA_unprep_propOm', 'AN_prep_propFP',  'AN_unprep_propFP',...
    'HA_prep_propFP', 'HA_unprep_propFP', 'nFP', 'nOmissions', 'nHits'};

T = mfile_table(:,interesting_vars);
T.geschlecht = categorical(T.geschlecht, [1, 2], {'male', 'female'});
T.Properties.VariableNames{'geschlecht'} = 'sex';
T.Properties.VariableNames{'alter'} = 'age';
T.happy_letter = upper(T.happy_letter);
T.propErrors = T.nErrors/200;

qual_vars = {'subjid', 'date', 'emg_data', 'nRpTrials', 'isExcluded', 'nErrors', 'propErrors', 'nFP', 'nOmissions', ...
    'AN_prep_meanRT', 'AN_unprep_meanRT', 'HA_prep_meanRT', 'HA_unprep_meanRT'};
T_qual = T(:, qual_vars);


%writetable(T, 'subjinfo.csv');

grpstats(T,[], {'mean', 'sem'}, 'datavars',{'HA_meanRT', 'AN_meanRT', 'prep_meanRT', 'unprep_meanRT'})

valid = [mean(T.HA_prep_meanRT); mean(T.AN_prep_meanRT)];
invalid = [mean(T.HA_unprep_meanRT); mean(T.AN_unprep_meanRT)];
anRT = table(valid, invalid, 'RowNames', {'Happiness', 'Anger'});

%% construct anova-table:
rt_vars = {'subjid', 'AN_prep_meanRT',  'AN_unprep_meanRT', 'HA_prep_meanRT', 'HA_unprep_meanRT'};
T_RT = T(:,rt_vars);

hit_vars = {'subjid', 'AN_prep_propHit',  'AN_unprep_propHit', 'HA_prep_propHit', 'HA_unprep_propHit'};
T_hit = T(:,hit_vars);

om_vars = {'subjid', 'AN_prep_propOm',  'AN_unprep_propOm', 'HA_prep_propOm', 'HA_unprep_propOm'};
T_om = T(:,om_vars);

fp_vars = {'subjid', 'AN_prep_propFP',  'AN_unprep_propFP', 'HA_prep_propFP', 'HA_unprep_propFP'};
T_fp = T(:,fp_vars);

%% long
T2 = stack(T_RT, rt_vars(2:end), 'NewDataVariableName','RT', 'IndexVariableName','Condition')
a = T2.Condition;
[b] = cellfun(@(x) strsplit(x, '_'), a, 'UniformOutput', false);
for i = 1:length(b)
    curcell = b{i};
    if i == 1
        em = curcell(1);
        val = curcell(2);
    else
        em = [em; curcell(1)];
        val = [val; curcell(2)];
    end;
end;

T2.Condition = [];
T2.em = em;
T2.val = val;



%% doch wide: funktionierender Code für RT
em = categorical({'AN'; 'AN'; 'HA'; 'HA'; });
val = categorical({'prep'; 'unprep'; 'prep'; 'unprep'});
factors = table(em,val);
rm_RT = fitrm(T_RT,'AN_prep_meanRT-HA_unprep_meanRT~1','WithinDesign',factors); 
rm_hit = fitrm(T_hit, 'AN_prep_propHit-HA_unprep_propHit~1', 'WithinDesign', factors);
rm_fp = fitrm(T_fp, 'AN_prep_propFP-HA_unprep_propFP~1', 'WithinDesign', factors);
rm_om = fitrm(T_om, 'AN_prep_propOm-HA_unprep_propOm~1', 'WithinDesign', factors);

myanova = ranova(rm_hit, 'WithinModel','em*val');

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

% läuft nicht wenn nicht identische felder, daher idee:
% loop through
subfields = {};
for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
     % concatenate
    subfields = [subfields fieldnames(subjinfo)];
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