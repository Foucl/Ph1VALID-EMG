function [ out ] = ph1valid02_stats( subjid )
%PH1VALID02_STATS Summary of this function goes here
%   Detailed explanation goes here
if  nargin == 0
    subjid = 'VP09';
end;
ph1valid_setup
prepro_file = fullfile(emg_out_path, subjid, [subjid '_prepro.mat']);
if ~exist(prepro_file, 'file')
    error([subjid ' not yet preprocessed, couldnt find ' prepro_file]);
end;

load(prepro_file);


mean_ANPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==51),2), 'omitnan');
 std_ANPrep = std(data.trialinfo(find(data.trialinfo(:,1)==51),2), 'omitnan');
 err_ANPrep = length(data.trialinfo(find(data.trialinfo(:,1)==51 & data.trialinfo(:,5)==1),2));
 ommiss_ANPrep = length(data.trialinfo(find(data.trialinfo(:,1)==51 & data.trialinfo(:,5)==2),2));
 fp_ANPrep = length(data.trialinfo(find(data.trialinfo(:,1)==51 & data.trialinfo(:,5)==3),2));
 
 mean_HAPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==52),2), 'omitnan');
 std_HAPrep = std(data.trialinfo(find(data.trialinfo(:,1)==52),2), 'omitnan');
 err_HAPrep = length(find(data.trialinfo(:,1)==52 & data.trialinfo(:,5)==1));
 ommiss_HAPrep = length(find(data.trialinfo(:,1)==52 & data.trialinfo(:,5)==2));
 fp_HAPrep = length(find(data.trialinfo(:,1)==52 & data.trialinfo(:,5)==3));
 
 mean_ANUnPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==61),2), 'omitnan');
 std_ANUnPrep = std(data.trialinfo(find(data.trialinfo(:,1)==61),2), 'omitnan');
 err_ANUnPrep = length(find(data.trialinfo(:,1)==61 & data.trialinfo(:,5)==1));
 ommiss_ANUnPrep = length(find(data.trialinfo(:,1)==61 & data.trialinfo(:,5)==2));
 fp_ANUnPrep = length(find(data.trialinfo(:,1)==61 & data.trialinfo(:,5)==3));
 
 mean_HAUnPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==62),2), 'omitnan');
 std_HAUnPrep = std(data.trialinfo(find(data.trialinfo(:,1)==62),2), 'omitnan');
 err_HAUnPrep = length(find(data.trialinfo(:,1)==62 & data.trialinfo(:,5)==1));
 ommiss_HAUnPrep = length(find(data.trialinfo(:,1)==62 & data.trialinfo(:,5)==2));
 fp_HAUnPrep = length(find(data.trialinfo(:,1)==62 & data.trialinfo(:,5)==3));
 
 out = [mean_ANPrep std_ANPrep err_ANPrep ommiss_ANPrep fp_ANPrep mean_HAPrep std_HAPrep err_HAPrep ommiss_HAPrep fp_HAPrep mean_ANUnPrep std_ANUnPrep err_ANUnPrep ommiss_ANUnPrep ...
      fp_ANUnPrep mean_HAUnPrep std_HAUnPrep err_HAUnPrep  ommiss_HAUnPrep fp_HAUnPrep];


 
 trialData = array2table(data.trialinfo,'VariableNames',{'Condition','ResponseTime','ResponseSample', 'ResponseSampleGlobal', 'type'});
 trialData.Condition = categorical(trialData.Condition);
 %trialData.type = categorical(trialData.type);
 trialData.Condition = renamecats(trialData.Condition,{'AN_prep'; 'HA_prep'; 'AN_unprep'; 'HA_unprep'});
 
 
statarray = grpstats(trialData,{'Condition', 'type'},{'mean', 'std'}, 'DataVars',{'ResponseTime'});


end

