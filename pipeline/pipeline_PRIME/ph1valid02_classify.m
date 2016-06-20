function [ data, Info ] = ph1valid02_classify( varargin )
%PH1VALID02_CLASSIFY Summary of this function goes here
%   Detailed explanation goes here

%% 0. setup
p=inputParser;

validSubjid = @(x) validateattributes(x,{'char'},{'size',[1,4]});
p.addParameter('subjid','VP15',validSubjid);
p.addParameter('which_th','Threshold');

p.parse(varargin{:});
subjid = p.Results.subjid;
which_th = p.Results.which_th;

SessionInfo = ph1valid_setup;

%% 1. get preprocessed data; if not found, preprocess
dataFile = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro.mat']);

if exist(dataFile, 'file')== 0
    ph1valid01_prepro(subjid);
end;

load(dataFile, 'data');

%% 2. read subjmfile (to get thresholds and excluded trials)

eval([subjid '_subjinfo']);

conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2;
        80 20 80 20};
    
con_wrong = conds(1, [3 4 1 2]);
th = nan(1,4);
th_o = nan(1,4);


for i = 1:size(conds, 2)
    th(i) = subjinfo.([conds{1,i} '_' which_th]);
    th_o(i) = subjinfo.([con_wrong{i} '_' which_th]);
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
    indices = find(data.trialinfo == trg);
    
    curdat = data.trial(indices);
    curtime = data.time(indices);
    
    fpTrials = nan(1,80);
    hitTrials = nan(1,80);
    omissionTrials = nan(1,80);
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
    Info.([con '_nOmissionTrials']) = length(omissionTrials);
    allFp{i} = fpTrials;
    Info.([con '_nFpTrials']) = length(fpTrials);
    allHits{i} = hitTrials;
    Info.([con '_nHitTrials']) = length(hitTrials);
    
end;

Info.allFp = [allFp{:}];
Info.allOmissions = [allOmissions{:}];
Info.allHits = [allHits{:}];
Info.nFP = nFP;
Info.nOmissions = nOmissions;
Info.nHits = nHits;

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
    indices = data.trialinfo == trg;
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT']) = mean_response_time;
    Info.([con '_sdRT']) = sd_response_time;
end;

% for factor emotion
em = {'AN', 'HA'};
em{2,1} = [conds{2,1} conds{2,2}];
em{2,2} = [conds{2,3} conds{2,4}];
for i = 1:size(em, 2)
    con = em{1,i};
    trg = em{2,i};
    indices = data.trialinfo == trg(1) | data.trialinfo == trg(2);
    curtrial = data.trialinfo(indices,:);
    %mean_response_time
    mean_response_time = mean(curtrial(:,3), 'omitnan');
    sd_response_time = std(curtrial(:,3), 'omitnan');
    Info.([con '_meanRT']) = mean_response_time;
    Info.([con '_sdRT']) = sd_response_time;
end;

% for factor preparedness/validity
val = {'prep', 'unprep'};
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
    Info.([con '_meanRT']) = mean_response_time;
    Info.([con '_sdRT']) = sd_response_time;
end;

%% some more calculations (hit-percentages etc.)
for i = 1:size(conds, 2)
    con = conds{1,i};
    nErr = subjinfo.([con '_nErrorTrials']); %conds{6,i};
    nDefault = conds{4,i};
    nHits = Info.([con '_nHitTrials']);
    nFP = Info.([con '_nFpTrials']);
    nOm = Info.([con '_nOmissionTrials']);
    Info.([con '_propHit']) = nHits / (nDefault - nErr);
    Info.([con '_propOm']) = nOm / (nDefault - nErr);
    Info.([con '_propFP']) = nFP / (nDefault - nErr);
end;

%% 5. dump data

save(fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro_class.mat']), 'data');

ph1valid_writeToSubjmfile(Info, subjid);


end

