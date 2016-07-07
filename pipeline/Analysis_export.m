%% setup paths

SessionInfo = ph1valid00_setup;
tableDir = fullfile(SessionInfo.outDir, 'tables');
subjmfileDir = SessionInfo.subjmfileDir;

%% read data table

T = readtable(fullfile(tableDir, 'subjinfo_behav.csv'));

%% describe data

% 46 subjects, excluded 4 for priming, 4 for switching: either problem with
% data acquisition or triggers -> n=42

%% setup plotting properties
% not necessary, just regexp vars out of T.Properties.VariableNames
inner_padding = [0.09, 0.08];
exp_long = {'Reponse Priming', 'Response Switching'};


%% descriptive plotting

% histogram for reaction times
export.histValidity(T, 50);

%% ANOVA / means
%generate tables
em = categorical({'AN'; 'AN'; 'HA'; 'HA'; });
val = categorical({'val'; 'inval'; 'val'; 'inval'});
valb = categorical({'inval'; 'val'; 'inval'; 'val'});
factors = table(em, val);
factorsb = table(em, valb);

anT = [];
rmT = [];
exp = {'Rp', 'Ts'};
for i = 1:numel(exp)
    rt = export.tblGrep(T, ['meanRT_' exp{i}]);
    propOm = export.tblGrep(T, ['propOm_' exp{i}]);
    propFP = export.tblGrep(T, ['propFP_' exp{i}]);
    propHit = export.tblGrep(T, ['propHit_' exp{i}]);
    
    form = ['AN_val_meanRT_' exp{i} '-HA_inval_meanRT_' exp{i} '~1'];
    rmT.(['rt_' exp{i}]) = fitrm(T(:, ['subjid', rt]),...
        form ,'WithinDesign',factors); 
    form = ['AN_inval_propOm_' exp{i} '-HA_val_propOm_' exp{i} '~1'];
    rmT.(['propOm_' exp{i}]) = fitrm(T(:, ['subjid', propOm]),...
        form ,'WithinDesign',factorsb);
    form = ['AN_inval_propFP_' exp{i} '-HA_val_propFP_' exp{i} '~1'];
    rmT.(['propFP_' exp{i}]) = fitrm(T(:, ['subjid', propFP]),...
        form ,'WithinDesign',factorsb); 
    form = ['AN_inval_propHit_' exp{i} '-HA_val_propHit_' exp{i} '~1'];
    rmT.(['propHit_' exp{i}]) = fitrm(T(:, ['subjid', propHit]),...
        form ,'WithinDesign',factorsb); 
end;


