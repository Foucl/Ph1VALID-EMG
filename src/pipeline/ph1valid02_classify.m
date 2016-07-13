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

if strcmpi(which_th, 'Threshold')
    th_str = '';
else
    th_str = '_CLEAN';
end;

SessionInfo = ph1valid00_setup;

% DONE:10 encode the threshold that was used in the filename AND in variables
% (? -> that would make the variable generation later more difficult ...)

%% 1. get preprocessed data; if not found, preprocess
dataFile = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_' experiment '.mat']);

if exist(dataFile, 'file')== 0
    ph1valid01_prepro(subjid, experiment);
end;

load(dataFile, 'data');

%% 2. read subjmfile (to get thresholds and excluded trials)

eval([subjid '_subjinfo']);
if strcmpi(subjinfo.(['isExcluded_' experiment]), 'yes');
    error([subjid ' is excluded from this experiment']);
end;

conds = prepro.defineConditions(subjinfo);
conds = conds.(experiment);

conds_half1 = conds(:,1:end/2); 
conds_half2 = conds(:,(end/2 + 1):end);
ch_wrong = [conds_half2{3,:} conds_half1{3,:}];
con_wrong = [conds_half2(1,:) conds_half1(1,:)];


%con_wrong = conds(1, [3 4 1 2]);
th = nan(1,length(conds));
th_o = nan(1,length(conds));


for i = 1:size(conds, 2)
    th(i) = subjinfo.([conds{1,i} '_' which_th '_' experiment]);
    th_o(i) = subjinfo.([con_wrong{i} '_' which_th '_' experiment]);
end;


%% 3. find ommissions and false positives
nOmissions = 0;
nFP = 0;
nHits = 0;

nCon = size(conds, 2);
Info = [];
data.trialinfo(:,3) = nan;
%ch_wrong = [conds{3,[3 4 1 2]}];
allOmissions = cell(1,nCon);
allFp = cell(1,nCon);
allHits = cell(1,nCon);
for i = 1:nCon
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
    Info.([con '_nOmissionTrials_' experiment th_str]) = length(omissionTrials);
    allFp{i} = fpTrials;
    Info.([con '_nFpTrials_' experiment th_str]) = length(fpTrials);
    allHits{i} = hitTrials;
    Info.([con '_nHitTrials_' experiment th_str]) = length(hitTrials);
    
end;

Info.(['allFp_' experiment th_str]) = [allFp{:}];
Info.(['allOmissions_' experiment th_str]) = [allOmissions{:}];
Info.(['allHits_' experiment th_str]) = [allHits{:}];
Info.(['nFP_' experiment th_str]) = nFP;
Info.(['nOmissions_' experiment th_str]) = nOmissions;
Info.(['nHits_' experiment th_str]) = nHits;

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
    Info.([con '_meanRT_' experiment th_str]) = mean_response_time;
    Info.([con '_sdRT_' experiment th_str]) = sd_response_time;
end;

% for factor emotion
% DONE:50 fix for Ts_fine

em = {'AN', 'HA'};
%em{2,1} = [conds{2,1} conds{2,2}];
em{2,1} = [conds{2,1:end/2}];
%em{2,2} = [conds{2,3} conds{2,4}];
em{2,2} = [conds{2,(end/2 + 1):end}];
for i = 1:size(em, 2)
    con = em{1,i};
    trg = em{2,i};
    indices = find(ismember(data.trialinfo, trg));
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT_' experiment th_str]) = mean_response_time;
    Info.([con '_sdRT_' experiment th_str]) = sd_response_time;
end;

% for factor preparedness/validity
% DONE:80 fix for Ts_fine: even
val = {'val', 'inval'};
[~, idx_inval] = export.cellGrep(conds(1,:), 'inval');
[~, idx_val] = export.cellGrep(conds(1,:), '_val');

val{2,1} = [conds{2,idx_val}];
val{2,2} = [conds{2,idx_inval}];
for i = 1:size(val, 2)
    con = val{1,i};
    trg = val{2,i};
    indices = data.trialinfo(:,1) == trg(1) | data.trialinfo(:,1) == trg(2);
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT_' experiment th_str]) = mean_response_time;
    Info.([con '_sdRT_' experiment th_str]) = sd_response_time;
end;

%% some more calculations (hit-percentages etc.)
for i = 1:size(conds, 2)
    con = conds{1,i};
    nErr = subjinfo.([con '_nErrorTrials_' experiment]); %conds{6,i};
    nDefault = subjinfo.([con '_nCleanTrials_' experiment]) + nErr;
    nHits = Info.([con '_nHitTrials_' experiment th_str]);
    nFP = Info.([con '_nFpTrials_' experiment th_str]);
    nOm = Info.([con '_nOmissionTrials_' experiment th_str]);
    Info.([con '_propHit_' experiment th_str]) = nHits / (nDefault - nErr);
    Info.([con '_propOm_' experiment th_str]) = nOm / (nDefault - nErr);
    Info.([con '_propFP_' experiment th_str]) = nFP / (nDefault - nErr);
end;

%% 5. dump data

save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_class_' experiment  th_str '.mat']), 'data');

io.writeToSubjmfile(Info, subjid);


end

