%% trying to read a FACET dataset after expanding fieldtrip io functions with readFACET_data, _events & _hdr

%TODO: concentrate von VP38

%% setup paths
SessionInfo = ph1valid00_setup;
addpath(fullfile(SessionInfo.projectBaseDir, 'facet_xcorr'));
fc_dir = fullfile(SessionInfo.dataDir, 'raw', 'FACET');
filename = fullfile(fc_dir, 'VP38.txt');
emg_file = fullfile(SessionInfo.emgRawDir, 'VP38', 'VP38_20160603-Deci.bdf');

%% setup parameters
prestim = 2.3;
poststim = 4.5;

%% get EMG data first (so FACET data can be upsampled)
cfg = [];
cfg.trialdef.prestim = prestim;
cfg.trialdef.poststim = poststim;
cfg.trialfun = 'trialfun_ph1valid_Rp';
cfg.dataset = emg_file;
cfg = ft_definetrial(cfg);

cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.1 0];
%cfg.channels = {'Joy Evidence', 'Anger Evidence'};
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


%% FACET-prpro
% 1.  read trial data and preprocess without filtering
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

%TODO: make good decision about demeaning
cfg.demean          = 'no';
cfg.baselinewindow  = [-0.1 0];
cfg.channel = {'Joy Evidence', 'Anger Evidence'};
data = ft_preprocessing(cfg);

% append beginning of trial (in frames/sampling points) to trialinfo:
data.trialinfo(:,2) = data.sampleinfo(:,1);

% stimulus should be presented on 70th frame of each trial:
data.trialinfo(:,3) = data.sampleinfo(:,1) + 70;

% also add end of trial
data.trialinfo(:,4) = data.sampleinfo(:,2);

%% artifact rejection

% 1.5: reject 'artifacts' (no face detected)
% TODO: facet-artifact detection
% TODO: document facet artefacts for VP38
cfg = [];
cfg.trl = trl;
cfg.continuous = 'no';
cfg.artfctdef.threshold.bpfilter = 'no';
cfg.artfctdef.threshold.min = -9000;
cfg.artfctdef.threshold.range = 900;
[cfg, artifact] = ft_artifact_threshold(cfg, data);

% keep track of rejected trials:
art_beg = cfg.artfctdef.threshold.artifact(:,1);
trl_beg = cfg.artfctdef.threshold.trl(:,1);
[~,~,exclTrials] = intersect(art_beg,trl_beg);
[~,cleanTrials] = setdiff(trl_beg,art_beg);
fprintf('%d trials excluded because no face was detected:\n', numel(exclTrials));
fprintf('%d ', exclTrials);
data.trialinfo(exclTrials,5) = 1;

%reject
data = ft_rejectartifact(cfg, data);

% remove those trials from EMG data too
cfg = [];
cfg.trials = cleanTrials;
data_emg = ft_selectdata(cfg, data_emg);

% visual inspection
% data.cfg.event = data.cfg.previous.previous.event
% ft_databrowser([], data);

% 2. upsample to match EMG-sampling rate
cfg = [];
cfg.time = data_emg.time;
data = ft_resampledata(cfg, data); % or rename to data_us?

cfg = [];
cfg.lpfilter        = 'yes';
cfg.lpfreq          = 10;
cfg.lpfiltord = 2; % for BVA (defaults) compatibility
data = ft_preprocessing(cfg, data);


%% combine both datasets

% try to concatenate both datasets
dat = ft_appenddata([], data, data_emg);

% z-transform amplitudes
% do that across trials and not within (makes the greater variance of facet
% data visible)
% dat.trial = cellfun(@ft_preproc_standardize, dat.trial, 'UniformOutput', false);
datArr = ft_preproc_standardize([dat.trial{:}]);
datArr = mat2cell(datArr,4,repmat(870,1,numel(cleanTrials)));
dat.trial = datArr;

% inspect
cfg = [];
cfg.trials = data.trialinfo == 51;
cfg.channel = {'Anger Evidence'};
ft_databrowser(cfg, ft_selectdata(cfg, dat));

%% concatenate all trials

data_concat = zeros(4,870*200);
time_concat = zeros(1,870*200);
for i = 1:length(dat.trial)
    data_concat(:,i*870-869:i*870) = dat.trial{i};
    time_concat(1,i*870-869:i*870) = dat.time{i}*i;
end;
dat_c = dat;
dat_c.trial = {data_concat};
dat_c.time = {time_concat};
%ft_databrowser([], dat_c);

%% more than one trial

% get all valid anger trials
Fs = 128;
indices = find(ismember(dat.trialinfo, [51]));
cfg = [];
cfg.trials = indices;
dat = ft_selectdata(cfg, dat);

r_raw = zeros(1,80);
SampleDiff = r_raw;
timeDiff = r_raw;
r_alg = r_raw;
for i = 1:length(dat.trial)
    curdat = dat.trial{i};
    T1 = curdat(3,:);
    T2 = curdat(2,:);
    r = corrcoef(T1, T2);
    r_raw(i) = r(1,2);
    [C1,lag1] = xcorr(T1,T2);

    [~,I] = max(abs(C1));
    SampleDiff(i) = lag1(I);
    timeDiff(i) = SampleDiff(i)/Fs;

    [T1_cor, T2_cor] = alignsignals(T1, T2,[], 'truncate');
    r = corrcoef(T1_cor, T2_cor, 'rows', 'complete');
    r_alg(i) = r(1,2);
end;

%[lagmax, lagmax_ind] = max(abs
%% select three trials: highest, lowest, closest to zero

[rmax, rmax_ind] = max(r_alg);
[rmin, rmin_ind] = min(r_alg);
[rzero, rzero_ind] = min(abs(r_alg)); % the same as rmin - problem trial?

S_fac = dat.trial{rmax_ind}(2,:);
S_emg = dat.trial{rmax_ind}(3,:);
Fs = 128;

[C1,lag1] = xcorr(S_fac,S_emg);

figure('Name','Reaction Time Grand Average','NumberTitle','off','Position',[450 450 800 400]);
ax(1) = subplot(311);
plot((0:numel(S_emg)-1)/Fs,S_emg,'k');
ylabel('EMG: Corrugator');
grid on
ax(2) = subplot(312);
plot((0:numel(S_fac)-1)/Fs,S_fac,'r');
ylabel('FACET: Anger Evidence Score');
grid on
ax(3) = subplot(313);
plot(lag1/Fs,C1,'k');
ylabel('Cross Correlation');
grid on
xlabel('Time (sec)');
linkaxes(ax(1:2),'x');


r_alg(rmax_ind)
r_raw(rmax_ind)
timeDiff(rmax_ind)
