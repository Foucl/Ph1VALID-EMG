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


for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_table = struct2table(sub);

interesting_vars = {'subjid', 'first_block', 'alter', 'geschlecht', 'nErrors', ...
    'AN_prep_nFpTrials', 'AN_prep_nOmissionTrials', 'AN_prep_nHitTrials', 'AN_unprep_nFpTrials', ...
    'AN_unprep_nOmissionTrials', 'AN_unprep_nHitTrials', 'HA_prep_nFpTrials', 'HA_prep_nOmissionTrials', ...
    'HA_prep_nHitTrials', 'HA_unprep_nFpTrials', 'HA_unprep_nOmissionTrials', 'HA_unprep_nHitTrials', ...
    'AN_prep_meanRT', 'AN_prep_sdRT', 'AN_unprep_meanRT', 'AN_unprep_sdRT', 'HA_prep_meanRT', ...
    'HA_prep_sdRT', 'HA_unprep_meanRT', 'HA_unprep_sdRT', 'AN_meanRT', 'AN_sdRT', 'HA_meanRT', 'HA_sdRT', ...
    'prep_meanRT', 'prep_sdRT', 'unprep_meanRT', 'unprep_sdRT', 'AN_prep_propHit',  'AN_unprep_propHit',...
    'HA_prep_propHit', 'HA_unprep_propHit'};

T = mfile_table(:,interesting_vars);

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

myanova = ranova(rm_hit, 'WithinModel','em*val');

plotprofile(rm_hit, 'val', 'Group', 'em');
