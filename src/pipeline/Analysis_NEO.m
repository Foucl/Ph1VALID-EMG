
SessionInfo = ph1valid00_setup;
tableDir = SessionInfo.tableDir;
subjmfileDir = SessionInfo.subjmfileDir;

%% read tables


% DONE:40 something

T_behav = readtable(fullfile(tableDir, 'subjinfo_behav.csv'));
T_neo = readtable(fullfile(tableDir, 'uniparkMapping.csv'));

T = join(T_behav, T_neo);

rtVars = export.tblGrep(T, ['propHit_Ts']);
neoVars = {'N_sum', 'E_sum'};

[R, pvalue] = corrplot(T(:, [rtVars, neoVars]), 'testR','on');

%% amplitudes maybe?

T_sig = readtable(fullfile(tableDir, 'subjinfo_amps.csv'));

T = join(T_sig, T_neo);

ampVars = export.tblGrep(T, 'MeanMaxAmp_Ts');
[R, pvalue] = corrplot(T(:,[ampVars, neoVars]));
