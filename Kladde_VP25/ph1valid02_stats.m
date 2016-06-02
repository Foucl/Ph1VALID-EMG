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
 miss_ANPrep = length(data.trialinfo(find(data.trialinfo(:,1)==51 & data.trialinfo(:,6)==1),2));
 
 mean_HAPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==52),2), 'omitnan');
 std_HAPrep = std(data.trialinfo(find(data.trialinfo(:,1)==52),2), 'omitnan');
 err_HAPrep = length(find(data.trialinfo(:,1)==52 & data.trialinfo(:,5)==1));
 miss_HAPrep = length(find(data.trialinfo(:,1)==52 & data.trialinfo(:,6)==1));
 
 mean_ANUnPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==61),2), 'omitnan');
 std_ANUnPrep = std(data.trialinfo(find(data.trialinfo(:,1)==61),2), 'omitnan');
 err_ANUnPrep = length(data.trialinfo(find(data.trialinfo(:,1)==61 & data.trialinfo(:,5)==1),2));
 miss_ANUnPrep = length(data.trialinfo(find(data.trialinfo(:,1)==61 & data.trialinfo(:,6)==1),2));
 
 mean_HAUnPrep = mean(data.trialinfo(find(data.trialinfo(:,1)==62),2), 'omitnan');
 std_HAUnPrep = std(data.trialinfo(find(data.trialinfo(:,1)==62),2), 'omitnan');
 err_HAUnPrep = length(data.trialinfo(find(data.trialinfo(:,1)==62 & data.trialinfo(:,5)==1),2));
 miss_HAUnPrep = length(data.trialinfo(find(data.trialinfo(:,1)==62 & data.trialinfo(:,6)==1),2));
 
 out = [mean_ANPrep std_ANPrep err_ANPrep miss_ANPrep mean_HAPrep std_HAPrep err_HAPrep miss_HAPrep mean_ANUnPrep std_ANUnPrep err_ANUnPrep miss_ANUnPrep ...
      mean_HAUnPrep std_HAUnPrep  err_HAUnPrep  miss_HAUnPrep];


 
 trialData = array2table(data.trialinfo,'VariableNames',{'Condition','ResponseTime','ResponseSample', 'ResponseSampleGlobal', 'error', 'miss', 'prepared', 'emotion'});
 trialData.Condition = categorical(trialData.Condition);
 trialData.error = logical(trialData.error);
 trialData.miss = logical(trialData.miss);
 trialData.prepared = categorical(trialData.prepared);
 trialData.emotion = categorical(trialData.emotion);
 trialData.Condition = renamecats(trialData.Condition,{'AN_prep'; 'HA_prep'; 'AN_unprep'; 'HA_unprep'});
 trialData.emotion = renamecats(trialData.emotion,{'angry'; 'happy'});
 trialData.prepared = renamecats(trialData.prepared,{'unprepared'; 'prepared'});
 
statarray = grpstats(trialData,{'Condition'},{'mean', @sum, 'std'}, 'DataVars',{'ResponseTime', 'error', 'miss'});

statarray = statarray(:,[1 2 3 5 7 10]);

end

