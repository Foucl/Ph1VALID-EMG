function [ sub ] = ph1valid09_getUnipark( input_args )
%PH1VALID_GETUNIPARK Summary of this function goes here
%   Detailed explanation goes here

%% setup
addpath(genpath('functions_ts'));
SessionInfo = ph1valid_setup;

%% read file
dataDir = fullfile(SessionInfo.dataDir, 'Unipark_Export');

fname = dir(fullfile(dataDir, '*.csv'));
%[~,idx] = max([fname.date]);
fname = fname(1).name;
dataFile = fullfile(dataDir, fname);
T = readtable(dataFile);

%% prepare data
int_vars = [1, 11:106];
T{:,int_vars} = cellfun(@str2num, T{:,int_vars}, 'Uniform', 0);

T_neo = T(:,[1 10:106]);

excl_rows = [1:3 21];

T_neo(excl_rows,:) = [];

%% get subjmfiles

subjmfileDir = SessionInfo.subjmfileDir;

existingSubjmfiles = ls(subjmfileDir);
existingSubjmfiles = existingSubjmfiles(3:end,1:end-2);

normalizeStructs(existingSubjmfiles);

for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_pseudos = sub(:).pseudonym;

mfile_table = struct2table(sub);

mfile_table = mfile_table(:,{'subjid', 'pseudonym'});

poss_hits = cell(height(mfile_table),height(mfile_table));
poss_hits_psd = cell(height(mfile_table),height(mfile_table));

for i = 1:height(mfile_table)
    for j = 1:height(T_neo)
        hit = strncmpi(mfile_table{i,2}, T_neo{j,2}, 6);
        cur_hit = (T_neo{j, 'lfdn'});
        cur_hit_psd = T_neo{j, 'VpnCodeUNIPARK'};
        if hit
            poss_hits{i,j} = cell2mat(cur_hit);
            poss_hits_psd{i,j} = cell2mat(cur_hit_psd);
        end;
    end;
end;

%disp(poss_hits);
%poss_hits = poss_hits(~cellfun('isempty',poss_hits));
myHits_1 = cell(height(mfile_table),1);
myHits_psd_1 = cell(height(mfile_table),1);
myHits_2 = cell(height(mfile_table),1);
myHits_psd_2 = cell(height(mfile_table),1);
for i = 1:size(poss_hits, 1)
    myrow_psd = poss_hits_psd(i,~cellfun(@isempty, poss_hits_psd(i,:)));
    myrow = poss_hits(i, ~cellfun(@isempty, poss_hits(i,:)));
    if length(myrow_psd) > 1
        myHits_1{i} = myrow{1};
        myHits_psd_1{i} = myrow_psd{1};
        myHits_2{i} = myrow{2};
        myHits_psd_2{i} = myrow_psd{2};
    elseif ~isempty(myrow)
        myHits_1{i} = myrow{1};
        myHits_psd_1{i} = myrow_psd{1};
    end;
end;
mfile_table.lfdn_1 = myHits_1;
mfile_table.psd_1 = myHits_psd_1;
mfile_table.lfdn_2 = myHits_2;
mfile_table.psd_2 = myHits_psd_2;
mfile_table

%% alle klar identifizierten rauslöschen
mfile_table.lfdn_1([13, 21, 25, 30, 34, 36, 39, 45]) = {25, 34, 43, 45, 71, 53, 64, 79}';
indices = ~cellfun(@isempty, mfile_table.lfdn_1);
to_del = mfile_table.lfdn_1(indices);
to_del{35} = 79;
%mfile_table(indices,:) = [];

indices = [];
for i = 1:height(T_neo)
    if ismember(T_neo.lfdn{i}, [to_del{:}])
        indices = [indices i];
    end;
end;
%T_neo(indices,:) = [];

vars = T_neo.Properties.VariableNames(3:end);
N1_vars = vars(strncmp(vars,'N1',2));
N2_vars = vars(strncmp(vars,'N2',2));
N3_vars = vars(strncmp(vars,'N3',2));
N4_vars = vars(strncmp(vars,'N4',2));
N5_vars = vars(strncmp(vars,'N5',2));
N6_vars = vars(strncmp(vars,'N6',2));
N_vars = vars(strncmp(vars,'N',1));

E1_vars = vars(strncmp(vars,'E1',2));
E2_vars = vars(strncmp(vars,'E2',2));
E3_vars = vars(strncmp(vars,'E3',2));
E4_vars = vars(strncmp(vars,'E4',2));
E5_vars = vars(strncmp(vars,'E5',2));
E6_vars = vars(strncmp(vars,'E6',2));
E_vars = vars(strncmp(vars,'E',1));

rev_idx = cellfun('length', regexp(vars, '_R')) > 0;
rev_vars = vars(rev_idx);

%% recoding
for i = 1:length(vars)
    T_neo.(vars{i}) = cell2mat(T_neo.(vars{i}));
    if ismember(vars{i}, rev_vars)
        %T_neo.(vars(i)) = categorical(cell2mat(T_neo.(vars{i})), [1 2 3 4 5]);
        for j = 1:height(T_neo)
            curval = (T_neo{j, vars{i}});
            switch curval
                case 5
                    curval = 1;
                case 4
                    curval = 2;
                case 2
                    curval = 4;
                case 1
                    curval = 5;
            end;
            T_neo{j, vars{i}} = curval;
        end;
    end;
end;

%% aggregating
for i = 1:height(T_neo)
    T_neo.N1_sum(i) = sum(T_neo{i,N1_vars});
    T_neo.N2_sum(i) = sum(T_neo{i,N2_vars});
    T_neo.N3_sum(i) = sum(T_neo{i,N3_vars});
    T_neo.N4_sum(i) = sum(T_neo{i,N4_vars});
    T_neo.N5_sum(i) = sum(T_neo{i,N5_vars});
    T_neo.N6_sum(i) = sum(T_neo{i,N6_vars});
    T_neo.E1_sum(i) = sum(T_neo{i,E1_vars});
    T_neo.E2_sum(i) = sum(T_neo{i,E2_vars});
    T_neo.E3_sum(i) = sum(T_neo{i,E3_vars});
    T_neo.E4_sum(i) = sum(T_neo{i,E4_vars});
    T_neo.E5_sum(i) = sum(T_neo{i,E5_vars});
    T_neo.E6_sum(i) = sum(T_neo{i,E6_vars});
    T_neo.N_sum(i) = sum(T_neo{i,N_vars});
    T_neo.E_sum(i) = sum(T_neo{i,E_vars});
end;

%% transfering to mfile_table

T_neo.lfdn = cell2mat(T_neo.lfdn);
for i = 1:height(mfile_table)
    if ~isempty(mfile_table.lfdn_1{i})
        mfile_table.lfdn{i} = mfile_table.lfdn_1{i};
        pseudoUp = T_neo.lfdn == mfile_table.lfdn{i};    
        mfile_table.pseudoUnipark{i} = T_neo.VpnCodeUNIPARK{pseudoUp};
        mfile_table.N1_sum{i} = T_neo.N1_sum(pseudoUp);
        mfile_table.N2_sum{i} = T_neo.N2_sum(pseudoUp);
        mfile_table.N3_sum{i} = T_neo.N3_sum(pseudoUp);
        mfile_table.N4_sum{i} = T_neo.N4_sum(pseudoUp);
        mfile_table.N5_sum{i} = T_neo.N5_sum(pseudoUp);
        mfile_table.N6_sum{i} = T_neo.N6_sum(pseudoUp);
        mfile_table.N_sum{i} = T_neo.N_sum(pseudoUp);
        
        mfile_table.E1_sum{i} = T_neo.E1_sum(pseudoUp);
        mfile_table.E2_sum{i} = T_neo.E2_sum(pseudoUp);
        mfile_table.E3_sum{i} = T_neo.E3_sum(pseudoUp);
        mfile_table.E4_sum{i} = T_neo.E4_sum(pseudoUp);
        mfile_table.E5_sum{i} = T_neo.E5_sum(pseudoUp);
        mfile_table.E6_sum{i} = T_neo.E6_sum(pseudoUp);
        mfile_table.E_sum{i} = T_neo.E_sum(pseudoUp);
    end;
end;
myvars = {'N1_sum', 'N2_sum', 'N3_sum', 'N4_sum', 'N5_sum', 'N6_sum', 'N_sum', ...
    'E1_sum', 'E2_sum', 'E3_sum', 'E4_sum', 'E5_sum', 'E6_sum', 'E_sum'};
mfile_table{[3, 28, 38], 3:end} = {nan};

neo_table = varfun(@cell2mat, mfile_table, 'InputVariables', myvars);
neo_table.Properties.VariableNames = myvars;
mfile_table = mfile_table(:,[1 2 7:8]);
%mfile_table.lfdn(cellfun(@isempty, mfile_table.lfdn)) = {nan};
mfile_table.lfdn = cell2mat(mfile_table.lfdn);
mfile_table = [mfile_table neo_table];
mfile_table.Properties.VariableNames(3) = {'lfdnUnipark'};
writetable(mfile_table, 'uniparkMapping.csv');
excl = [3 28 38];
mfile_table.pseudonym{3} = nan;
S = table2struct(mfile_table);
S = rmfield(S, {'subjid', 'pseudonym'});
to_excl = mfile_table.lfdnUnipark;
T.lfdn = cell2mat(T.lfdn);
T_rest = T(~ismember(T.lfdn, to_excl), :);
writetable(T_rest, 'uniparkRest.csv');

for i = 1:length(S)
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end;
    subjid = ['VP' b];
    
    io.writeToSubjmfile(S(i), subjid);
     % concatenate
end;

function normalizeStructs(existingSubjmfiles)

subfields = cell(0,1);
for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
     % concatenate
    subfields = [subfields; fieldnames(subjinfo)];
end;
% 
% % find all unique fields
allfields = unique(subfields);
% 
% % do another loop and compare fieldnames with allfields, and create array of structs
for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
     % concatenate
    missingFields = setdiff(allfields, fieldnames(subjinfo));
     for j = 1:length(missingFields)
          subjinfo.(missingFields{j}) = nan;
     end;
    io.writeToSubjmfile(subjinfo, subjinfo.subjid);
end;

