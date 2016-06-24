input = mfile_table.Properties.VariableNames;
outidx = cellfun('length', regexp(input, 'AN_val')) > 0;
out = input(outidx)

myVars = {'subjid', 'nRpTrials', 'nTsTrials', 'nErrors_Rp', 'nErrors_Ts', 'isExcluded', 'isExcluded_Rp', 'isExcluded_Ts'};
T = mfile_table(:, myVars);

T.propErrors_Rp = T.nErrors_Rp./T.nRpTrials;
T.propErrors_Ts = T.nErrors_Ts./T.nTsTrials;

finalVars = {'subjid', 'nRpTrials', 'nTsTrials', 'propErrors_Rp', 'propErrors_Ts', 'isExcluded_Rp', 'isExcluded_Ts'};

T = T(:, finalVars)

writetable(T, 'subjinfo2.csv')
