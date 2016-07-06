
%% Setup
SessionInfo = ph1valid00_setup;
fc_dir = fullfile(SessionInfo.dataDir, 'FACET');
emg_dir = SessionInfo.emgRawDir;
out_dir = fullfile(SessionInfo.outDir, 'xcorrOut', 'concat_prepro_out');

prestim = 2.3;
poststim = 4.5;



for i = 6:6
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end;
    subjid = ['VP' b];
    dataDir = fullfile(emg_dir, subjid);
    fname = dir(fullfile(dataDir, '*.bdf'));
    [~,idx] = max([fname.bytes]);
    fname = fname(idx).name;  % take the largest file
    emg_file = fullfile(dataDir, fname);
    
    dataDir = fullfile(fc_dir);
    fname = dir(fullfile(dataDir,[subjid '.txt']));
    filename = fullfile(dataDir, fname.name);
    
    % get EMG
    cfg = [];
    cfg.trialdef.prestim = prestim;
    cfg.trialdef.poststim = poststim;
    cfg.trialfun = 'trialfun_ph1valid_Rp';
    cfg.dataset = emg_file;
    cfg = ft_definetrial(cfg);
    
    cfg.lpfilter        = 'yes';
    cfg.lpfreq          = 10;
    cfg.lpfiltord = 2; % for BVA (defaults) compatibility
    data_emg = ft_preprocessing(cfg);
    
    bipolar.labelorg  = {'EXG1', 'EXG2', 'EXG3', 'EXG4'};
    bipolar.labelnew  = {'Cor', 'Zyg'};
    bipolar.tra       = [
        +1 -1  0  0
        0  0 +1 -1
        ];
    
    data_emg = ft_apply_montage(data_emg, bipolar);
    data_emg.trial = cellfun(@abs,data_emg.trial, 'UniformOutput', false);
    
    %get FACET
    cfg = [];
    cfg.trialdef.prestim = prestim;
    cfg.trialdef.poststim = poststim;
    cfg.trialfun = 'trialfun_ph1valid_Rp_facet';
    cfg.dataformat = 'facet_txt';
    cfg.headerformat = 'facet_txt';
    cfg.eventformat = 'facet_txt';
    cfg.dataset = filename;
    cfg = ft_definetrial(cfg);
    trl = cfg.trl;
    cfg.channel = {'Joy Evidence', 'Anger Evidence'};
    
    data_facet = ft_preprocessing(cfg);
    
    % 2. upsample to match EMG-sampling rate
    cfg.time = data_emg.time;
    data_facet = ft_resampledata(cfg, data_facet); % or rename to data_us?
    
    cfg = [];
    cfg.lpfilter        = 'yes';
    cfg.lpfreq          = 10;
    cfg.lpfiltord = 2; % for BVA (defaults) compatibility
    data_facet = ft_preprocessing(cfg, data_facet);
    
    dat_combined = ft_appenddata([], data_facet, data_emg);
    
    % z-transform amplitudes
    % do that across trials and not within (makes the greater variance of facet
    % data visible)
    % dat.trial = cellfun(@ft_preproc_standardize, dat.trial, 'UniformOutput', false);
    datArr = ft_preproc_standardize([dat_combined.trial{:}]);
    datArr = mat2cell(datArr,4,repmat(870,1,200));
    dat_combined.trial = datArr;
    
    %% concatenate all trials
    
    data_concat = zeros(4,870*200);
    time_concat = zeros(1,870*200);
    for i = 1:length(dat_combined.trial)
        data_concat(:,i*870-869:i*870) = dat_combined.trial{i};
        time_concat(1,i*870-869:i*870) = dat_combined.time{i}*i;
    end;
    dat_combined_single = dat_combined;
    dat_combined_single.trial = {data_concat};
    dat_combined_single.time = {time_concat};
    
    save(fullfile(out_dir, [subjid '.mat']), 'data_emg', 'data_facet', 'dat_combined', 'dat_combined_single'); 
    
end