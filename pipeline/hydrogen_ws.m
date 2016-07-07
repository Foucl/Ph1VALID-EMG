%% table searcher
input = T.Properties.VariableNames;
outidx = cellfun('length', regexp(input, 'trial', 'ignorecase')) > 0;
out = input(outidx);
celldisp(out)


%% other stuff
tic;
ph1valid03_prepro_loop('both', 'Rp', 'Threshold');
ph1valid03_prepro_loop('both', 'Ts', 'Threshold');
toc