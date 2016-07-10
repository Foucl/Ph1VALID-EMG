classdef prepro
    %PREPRO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function [ conds ] = defineConditions(subjinfo)
            conds.Rp = {'AN_val' 'AN_inval' 'HA_val' 'HA_inval';
                51 61 52 62;
                1 1 2 2};
            
            if strcmpi(subjinfo.happy_letter, 'm')
                conds.Ts = {'AN_val' 'AN_inval' 'HA_val' 'HA_inval';
                    [141 142] [151:153] [241 242] [251:253];
                    1 1 2 2};
            else
                conds.Ts = {'AN_val' 'AN_inval' 'HA_val' 'HA_inval';
                    [241 242] [251:253] [141 142] [151:153] ;
                    1 1 2 2};
            end;
        end
        function [ dataFile ] = validate( subjid, experiment, SessionInfo )
            %PH1VALID_VALIDATERP Checks Validity of RP segment in EMG data
            %   returns file handle
            if strcmp(subjid, 'VP01') 
                error('VP01: no triggers no trials');
            end;
            % get the folder
            dataDir = fullfile(SessionInfo.emgRawDir, subjid);
            assert(exist(dataDir, 'dir')==7,'custom:no_data', 'no such directory: %s', dataDir);
            
            % get the file
            fname = dir(fullfile(dataDir, '*.bdf'));
            assert(~isempty(fname),'custom:no_data', 'No *.bdf file found in %s.', dataDir);
            
            if length(fname) > 1
                warning('multiple *.bdf files found, caution advised');
            end;
            [~,idx] = max([fname.bytes]);
            fname = fname(idx).name;  % take the largest file
          
            dataFile = fullfile(dataDir, fname);
        end
        
        function [ data ] = basicPrepro (dataFile, subjid, experiment)
            
            if strcmpi(experiment, 'Rp')
                bl = {[-2 -1.8] [-0.1 0]};
                sgm = [2 2.5];
            else %switching
                bl = {[-0.1 0]};
                sgm = [0.6 2.6];
            end;
            
            % check date of recording (fieldtrip doesn't seem to be able to)
            Info.emg_data = 'yes';
            hdr = ImportBDFHeader(dataFile);
            Info.date = datetime([hdr.dataDate '_' hdr.dataTime],'InputFormat','dd.MM.yy_HH.mm.ss');
            
            %define trials
            cfg = [];
            cfg.trialdef.prestim = sgm(1);
            cfg.trialdef.poststim = sgm(2);
            cfg.trialfun = ['trialfun_ph1valid_' experiment];
            cfg.dataset = dataFile;
            try
                cfg = ft_definetrial(cfg);
            catch ME
                %disp(ME);
                a = strsplit(ME.identifier, '_');
                Info.(['n' experiment 'Trials']) = str2double(a{2});
                Info.(['isExcluded_' experiment]) = 'yes';
                io.writeToSubjmfile(Info, subjid);
                rethrow(ME);
            end;
            
            Info.(['n' experiment 'Trials']) = length(cfg.trl);
            io.writeToSubjmfile(Info, subjid);
            
            %%% preprocess
            % baseline correction, low pass filter (10Hz, order 2)
            cfg.demean          = 'yes';
            cfg.baselinewindow  = bl{1};
            cfg.lpfilter        = 'yes';
            cfg.lpfreq          = 10;
            cfg.lpfiltord = 2; % for BVA (defaults) compatibility
            data{1} = ft_preprocessing(cfg);
            if strcmpi(experiment, 'Rp')
                cfg.baselinewindow = bl{2};
                data{2} = ft_preprocessing(cfg);
            end;
            
            bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
            bipolar.labelnew  = {'Cor', 'Zyg'};
            bipolar.tra       = [
                +1 -1  0  0
                0  0 +1 -1
                ];
            
            data = cellfun(@(x) ft_apply_montage(x, bipolar), data, 'UniformOutput', false);
            
            for i = 1:length(data)
                data{i}.trial = cellfun(@abs,data{i}.trial, 'UniformOutput', false);
            end;
        end
        function [ Info, data ] = getThresholds(data, Info, conds, type, experiment)
            % recalculate clean thresholds
            for i = 1:size(conds,2)
                con = conds{1,i};
                chani = conds{3,i};
                trg = conds{2,i};
                indices = find(ismember(data.trialinfo, trg));
                curdat = data.trial(indices);
                curtime = data.time(indices);
                curtime = cell2mat(curtime');
                [amps, ind_amps] = cellfun(@(x) max(x(chani,:)), curdat);
                amp_times = arrayfun(@(n) (curtime(n,ind_amps(n))), 1:size(curtime,1));
                
                data.trialinfo(indices,4) = amps';
                data.trialinfo(indices,5) = amp_times';
                Info.([con '_' type 'MaxAmp_' experiment]) = max(amps);
                Info.([con '_' type 'MeanMaxAmp_' experiment]) = mean(amps);
                Info.([con '_' type 'SdMaxAmp_' experiment]) = std(amps);
                Info.([con '_' type 'MeanMaxAmpTime_' experiment]) = mean(amp_times);
                Info.([con '_' type 'Threshold_' experiment]) = 0.25*mean(amps);
            end;
        end
        
        function [ Info, data ] = getErrors(data, Info, conds, experiment)
            nErrors = 0;
            ch_wrong = [conds{3,[3 4 1 2]}];
            con_wrong = conds(1, [3 4 1 2]);
            allErrors = cell(1,4);
            for i = 1:size(conds, 2)
                con = conds{1,i};
                trg = conds{2,i};
                chani = conds{3,i};
                chani_o = ch_wrong(i);
                th = Info.([con '_Threshold_' experiment]);
                th_o = Info.([con_wrong{i} '_Threshold_' experiment]);
                indices = find(ismember(data.trialinfo, trg));
                curdat = data.trial(indices);
                curtime = data.time(indices);
                
                errorTrials = nan(80,1);
                k = 1;
                for j = 1:length(curdat)
                    idx = find(curdat{j}(chani,:) >= th, 1);  % indices of 'hits': => threshold in correct channel
                    idx_o = find(curdat{j}(chani_o,:) >=th_o,1); % indices of hits-in-wrong-channel: wrong emotions shown
                    if ~isempty(idx_o) && (curtime{j}(idx_o) < 0) && (-0.5 < curtime{j}(idx_o))   % current trial is wrong
                        errorTrials(k) = indices(j);
                        data.trialinfo(indices(j),2) = 69;
                        k = k +1;
                    elseif ~isempty(idx) && (curtime{j}(idx) < 0) && (-0.5 < curtime{j}(idx))
                        errorTrials(k) = indices(j);
                        data.trialinfo(indices(j),2) = 60;
                        k = k+1;
                    else
                        data.trialinfo(indices(j),2) = nan;
                    end;
                end;
                errorTrials(isnan(errorTrials)) = [];
                Info.([con '_errorTrials_' experiment]) = errorTrials.';
                Info.([con '_nErrorTrials_' experiment]) = length(errorTrials);
                Info.([con '_nCleanTrials_' experiment]) = length(indices) - length(errorTrials);
                allErrors{i} = errorTrials';
                nErrors = nErrors + length(errorTrials);
            end;
            Info.(['nErrors_' experiment]) = nErrors;
            Info.(['allErrors_' experiment]) = [allErrors{:}];
        end
    end
end
