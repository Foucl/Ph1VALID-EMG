%% ph1valid06_GAstats

ph1valid_setup;


out = [];
for i = 10:25
    out(i-9,:) = ph1valid02_stats(['VP' num2str(i)]);
end

% werte in out: [mean_ANPrep std_ANPrep err_ANPrep miss_ANPrep mean_HAPrep std_HAPrep err_HAPrep miss_HAPrep mean_ANUnPrep std_ANUnPrep err_ANUnPrep miss_ANUnPrep ...
      %mean_HAUnPrep std_HAUnPrep  err_HAUnPrep  miss_HAUnPrep
 
 delcols = [2 6 10 14];
 out(:,delcols) = [];
      
 vars = {'an_prep_rt', 'an_prep_err', 'an_prep_miss', 'ha_prep_rt', 'ha_prep_err', 'ha_prep_miss', ...
     'an_unprep_rt', 'an_unprep_err', 'an_unprep_miss', 'ha_unprep_rt', 'ha_unprep_err', 'ha_unprep_miss'};
 
tbl = array2table(out,'VariableNames',vars);
statarray = grpstats(tbl,[],{'mean','std'});
