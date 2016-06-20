%% ph1valid06_GAstats

global Sess;
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;


out = [];
for i = 10:25
    out(i-9,:) = ph1valid02_stats(['VP' num2str(i)]);
end

% werte in out: [mean_ANPrep std_ANPrep err_ANPrep ommiss_ANPrep fp_ANPrep mean_HAPrep std_HAPrep err_HAPrep ommiss_HAPrep fp_HAPrep mean_ANUnPrep std_ANUnPrep err_ANUnPrep ommiss_ANUnPrep ...
      %fp_ANUnPrep mean_HAUnPrep std_HAUnPrep err_HAUnPrep  ommiss_HAUnPrep fp_HAUnPrep]
 
 delcols = [2 7 12 17];
 out(:,delcols) = [];
      
 vars = {'an_prep_rt', 'an_prep_err', 'an_prep_ommiss', 'an_prep_fp' 'ha_prep_rt', 'ha_prep_err', 'ha_prep_ommiss', 'ha_prep_fp', ...
     'an_unprep_rt', 'an_unprep_err', 'an_unprep_ommiss', 'an_unprep_fp', 'ha_unprep_rt', 'ha_unprep_err', 'ha_unprep_miss', 'ha_unprep_fp'};
 
tbl = array2table(out,'VariableNames',vars);
statarray = grpstats(tbl,[],{'mean','std'});