input = mfile_table.Properties.VariableNames;
outidx = cellfun('length', regexp(input, 'MeanMaxAmp')) > 0;
out = input(outidx)