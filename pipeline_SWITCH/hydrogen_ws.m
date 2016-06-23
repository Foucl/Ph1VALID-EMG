input = mfile_table.Properties.VariableNames;
outidx = cellfun('length', regexp(input, 'Trials')) > 0;
out = input(outidx)

