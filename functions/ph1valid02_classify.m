function [ data, Info ] = ph1valid02_classify( subjid )
%PH1VALID02_CLASSIFY Summary of this function goes here
%   Detailed explanation goes here

%% 0. setup
p=inputParser;

validSubjid = @(x) validateattributes(x,{'char'},{'size',[1,4]});
p.addRequired('subjid',validSubjid);

p.parse(subjid);

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

%% 1. get preprocessed data; if not found, preprocess
dataFile = fullfile(SessionInfo.emgPreproDir, subjid, [subjid '_prepro.mat']);

if exist(dataFile, 'file')==0
    ph1valid01_prepro(subjid);
end;

data = load(dataFile, 'data');
data = data.data;


%% 2. read subjmfile (to get thresholds and excluded trials)

eval([subjid '_subjinfo']);
th = [];
conds = {'AN_prep' 'AN_unprep' 'HA_prep' 'HA_unprep';
        51 61 52 62;
        1 1 2 2;
        80 20 80 20};
 
for i = 1:size(conds, 2)
    th(i) = subjinfo.([conds{1,i} '_Threshold']);
    conds{5,i} = th(i);
    errorTrials{i} = subjinfo.([conds{1,i} '_errorTrials']);
    conds{6,i} = length(errorTrials{i});
end;
%conds(5,:) = errorTrials;

allErrors = subjinfo.allErrors;

%% 3. find ommissions and false positives
nOmissions = 0;
allOmissions = [];
nFP = 0;
allFP = [];
nHits = 0;
allHits = [];

Info = [];
data.trialinfo(:,3) = nan;
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    chani = conds{3,i};
       
    %corInd = setdiff(1:size(data.trialinfo, 1),allErrors);
    indices = find(data.trialinfo == trg);
    %indices = intersect(indices, corInd);
    
    curdat = data.trial(indices);
    curtime = data.time(indices);
    
    switch i
       case 1
           th_o = th(3);
           chani_o = 2;
       case 2
           th_o = th(4);
           chani_o = 2;
       case 3
           th_o = th(1);
           chani_o = 1;
       case 4
           th_o = th(2);
           chani_o = 1;
    end;
    
    fpTrials = [];
    hitTrials = [];
    omissionTrials = [];
    for j = 1:length(curdat)
        % start searching only after 0
        zero = find(curtime{j} >= 0, 1);
        
        idx = find(curdat{j}(chani,zero:end) >= th(i), 1);  % indices of 'hits': => threshold in correct channel
        idx = idx + zero;
        idx_o = find(curdat{j}(chani_o,zero:end) >=th_o,1); % indices of hits-in-wrong-channel: wrong emotions shown
        idx_o = idx_o + zero;
        % check if idx and/or idx_o refer to timepoints < -.3 -> search
        % until beyond 1
        
        % idx empty & idx_o empty -> ommission: increment & store
        % idx empty & idx_o ~empty -> FP: increment & store
        % idx ~empty -> hit: increment & store & store time
        if (isempty(idx)) && (isempty(idx_o))
            data.trialinfo(indices(j),2) = 59; % 59: code for omission
            omissionTrials = [omissionTrials indices(j)];
            nOmissions = nOmissions + 1;
        elseif (isempty(idx)) && (~isempty(idx_o))
            data.trialinfo(indices(j),2) = 50; % 50: code for FP
            fpTrials = [fpTrials indices(j)];
            nFP = nFP + 1;
        else           
            data.trialinfo(indices(j),2) = 0; % 0: code for Hit
            hitTrials = [hitTrials indices(j)];
            nHits = nHits + 1;
            time = curtime{j}(idx);
            data.trialinfo(indices(j),3) = time;
        end; 
    end;
    Info.([con '_nFpTrials']) = length(fpTrials);
    allFP = [allFP fpTrials];
    Info.([con '_nOmissionTrials']) = length(omissionTrials);
    allFP = [allFP fpTrials];
    Info.([con '_nHitTrials']) = length(hitTrials);
    allHits = [allHits hitTrials];
    
end;
Info.allFP = allFP;
Info.allOmissions = allOmissions;
Info.allHits = allHits;
Info.nFP = nFP;
Info.nOmissions = nOmissions;
Info.nHits = nHits;

%% 4. Calculate Averages, SD
% for individual conditions
for i = 1:size(conds, 2)
    con = conds{1,i};
    trg = conds{2,i};
    indices = find(data.trialinfo == trg);
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
    indices = find(data.trialinfo == trg(1) | data.trialinfo == trg(2));
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
for i = 1:size(em, 2)
    con = val{1,i};
    trg = val{2,i};
    indices = find(data.trialinfo == trg(1) | data.trialinfo == trg(2));
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
    trg = conds{2,i};
    nErr = conds{6,i};
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

