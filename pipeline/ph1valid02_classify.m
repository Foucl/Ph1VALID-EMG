function [ data, Info ] = ph1valid02_classify( subjid, which_th, experiment )
%PH1VALID02_CLASSIFY Summary of this function goes here
%   Detailed explanation goes here

%% 0. setup

if nargin < 1
    subjid = 'VP16';
    which_th = 'Threshold';
    experiment = 'Rp';
elseif nargin < 2
    which_th = 'Threshold';
    experiment = 'Rp';
elseif nargin < 3
    experiment = 'Rp';
end;

SessionInfo = ph1valid00_setup;

%% 1. get preprocessed data; if not found, preprocess
dataFile = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_' experiment '.mat']);

if exist(dataFile, 'file')== 0
    ph1valid01_prepro(subjid, experiment);
end;

load(dataFile, 'data');

%% 2. read subjmfile (to get thresholds and excluded trials)

eval([subjid '_subjinfo']);

conds = prepro.defineConditions(subjinfo);
conds = conds.(experiment);
    
con_wrong = conds(1, [3 4 1 2]);
th = nan(1,4);
th_o = nan(1,4);


for i = 1:size(conds, 2)
    th(i) = subjinfo.([conds{1,i} '_' which_th '_' experiment]);
    th_o(i) = subjinfo.([con_wrong{i} '_' which_th '_' experiment]);
end;


%% 3. find ommissions and false positives
nOmissions = 0;
nFP = 0;
nHits = 0;

Info = [];
data.trialinfo(:,3) = nan;
ch_wrong = [conds{3,[3 4 1 2]}];
allOmissions = cell(1,4);
allFp = cell(1,4);
allHits = cell(1,4);
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    chani = conds{3,i};
    chani_o = ch_wrong(i);
    indices = find(ismember(data.trialinfo, trg));
    
    curdat = data.trial(indices);
    curtime = data.time(indices);
    
    fpTrials = nan(1,100);
    hitTrials = nan(1,100);
    omissionTrials = nan(1,100);
    for j = 1:length(curdat)
        % start searching only after 0
        zero = find(curtime{j} >= 0, 1);
        
        idx = find(curdat{j}(chani,zero:end) >= th(i), 1);  % indices of 'hits': => threshold in correct channel
        idx = idx + zero;
        idx_o = find(curdat{j}(chani_o,zero:end) >=th_o(i),1); % indices of hits-in-wrong-channel: wrong emotions shown
        idx_o = idx_o + zero;
       
        if (isempty(idx)) && (isempty(idx_o))
            data.trialinfo(indices(j),2) = 59; % 59: code for omission
            omissionTrials(j) = indices(j);
            nOmissions = nOmissions + 1;
        elseif (isempty(idx)) && (~isempty(idx_o))
            data.trialinfo(indices(j),2) = 50; % 50: code for FP
            fpTrials(j) = indices(j);
            nFP = nFP + 1;
        else           
            data.trialinfo(indices(j),2) = 0; % 0: code for Hit
            hitTrials(j) = indices(j);
            nHits = nHits + 1;
            time = curtime{j}(idx);
            data.trialinfo(indices(j),3) = time;
        end; 
    end;
    omissionTrials(isnan(omissionTrials)) = [];
    fpTrials(isnan(fpTrials)) = [];
    hitTrials(isnan(hitTrials)) = [];
    
    allOmissions{i} = omissionTrials;
    Info.([con '_nOmissionTrials_' experiment]) = length(omissionTrials);
    allFp{i} = fpTrials;
    Info.([con '_nFpTrials_' experiment]) = length(fpTrials);
    allHits{i} = hitTrials;
    Info.([con '_nHitTrials_' experiment]) = length(hitTrials);
    
end;

Info.(['allFp_' experiment]) = [allFp{:}];
Info.(['allOmissions_' experiment]) = [allOmissions{:}];
Info.(['allHits_' experiment]) = [allHits{:}];
Info.(['nFP_' experiment]) = nFP;
Info.(['nOmissions_' experiment]) = nOmissions;
Info.(['nHits_' experiment]) = nHits;

maskEmptyId = structfun(  @(a)isempty(a), Info )';
names = fieldnames(Info);
emptyFields = names(maskEmptyId);
if ~isempty(emptyFields)
    for i = 1:length(emptyFields)
        Info.(emptyFields{i}) = [];
    end;
end;

%% 4. Calculate Averages, SD
% for individual conditions
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    indices = find(ismember(data.trialinfo, trg));
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT_' experiment]) = mean_response_time;
    Info.([con '_sdRT_' experiment]) = sd_response_time;
end;

% for factor emotion
em = {'AN', 'HA'};
em{2,1} = [conds{2,1} conds{2,2}];
em{2,2} = [conds{2,3} conds{2,4}];
for i = 1:size(em, 2)
    con = em{1,i};
    trg = em{2,i};
    indices = find(ismember(data.trialinfo, trg));
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT_' experiment]) = mean_response_time;
    Info.([con '_sdRT_' experiment]) = sd_response_time;
end;

% for factor preparedness/validity
val = {'val', 'inval'};
val{2,1} = [conds{2,1} conds{2,3}];
val{2,2} = [conds{2,2} conds{2,4}];
for i = 1:size(val, 2)
    con = val{1,i};
    trg = val{2,i};
    indices = data.trialinfo(:,1) == trg(1) | data.trialinfo(:,1) == trg(2);
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT_' experiment]) = mean_response_time;
    Info.([con '_sdRT_' experiment]) = sd_response_time;
end;

%% some more calculations (hit-percentages etc.)
for i = 1:size(conds, 2)
    con = conds{1,i};
    nErr = subjinfo.([con '_nErrorTrials_' experiment]); %conds{6,i};
    nDefault = subjinfo.([con '_nCleanTrials_' experiment]) + nErr;
    nHits = Info.([con '_nHitTrials_' experiment]);
    nFP = Info.([con '_nFpTrials_' experiment]);
    nOm = Info.([con '_nOmissionTrials_' experiment]);
    Info.([con '_propHit_' experiment]) = nHits / (nDefault - nErr);
    Info.([con '_propOm_' experiment]) = nOm / (nDefault - nErr);
    Info.([con '_propFP_' experiment]) = nFP / (nDefault - nErr);
end;

%% 5. dump data

save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_class_' experiment '.mat']), 'data');

io.writeToSubjmfile(Info, subjid);


end

