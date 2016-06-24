input = mfile_table.Properties.VariableNames;
outidx = cellfun('length', regexp(input, 'state')) > 0;
out = input(outidx)



tic;
ph1valid03_prepro_loop('both', 'Rp', 'Threshold');
ph1valid03_prepro_loop('both', 'Ts', 'Threshold');
toc