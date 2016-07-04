%% trying to read a FACET dataset after expanding fieldtrip io functions with readFACET_data, _events & _hdr


%% setup paths
SessionInfo = ph1valid00_setup;
fc_dir = fullfile(SessionInfo.dataDir, 'FACET');
filename = fullfile(fc_dir, 'Dump046_VP46.txt');
emg_file = fullfile(SessionInfo.emgRawDir, 'VP46', 'VP46_20160610-Deci.bdf');

%% get EMG data (so FACET data can be upsampled)
cfg = [];
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 2.5;
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
cfg.trialdef.prestim = 2;
cfg.trialdef.poststim = 2.5;
cfg.trialfun = 'trialfun_ph1valid_Rp_facet';
cfg.dataformat = 'facet_txt';
cfg.headerformat = 'facet_txt';
cfg.eventformat = 'facet_txt';
cfg.dataset = filename;
cfg = ft_definetrial(cfg);
trl = cfg.trl;
cfg.demean          = 'yes';
cfg.baselinewindow  = [-0.1 0];
cfg.channel = {'Joy Evidence', 'Anger Evidence'};

data = ft_preprocessing(cfg);

% 2. upsample to EMG-sampling rate
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
dat.trial = cellfun(@ft_preproc_standardize, dat.trial, 'UniformOutput', false);

% inspect
cfg = [];
cfg.channel = {'Cor', 'Anger Evidence'};
ft_databrowser(cfg, dat);

%% try cross correlations

% with first trial only:
dat_corr = dat.trial{1}; % 4x576 array: Joy/Anger Evidence, Cor, Zyg
dat_corr_labels = dat.label;

% because I'm lazy: use variable names of Matlab xcorr-tutorial
T1 = dat_corr(3,:);
T2 = dat_corr(2,:);
Fs1 = 128;
Fs2 = Fs1;
Fs = Fs1;

% display first trial
figure
ax(1) = subplot(311);
plot((0:numel(T1)-1)/Fs1,T1,'k');
ylabel('EMG: Corrugator');
grid on
ax(2) = subplot(312);
plot((0:numel(T2)-1)/Fs2,T2,'r');
ylabel('FACET: Anger Evidence');
grid on

%axis([0 1.61 -4 4])

% cross correlate Corrugator & Anger Evidence in first trial
[C1,lag1] = xcorr(T1,T2);

% visualize the cross-correlation
ax(3) = subplot(313);
plot(lag1/Fs,C1,'k');
ylabel('Cross Correlation');
grid on
xlabel('Time (secs)');
linkaxes(ax(1:2),'x');

% check lag
[~,I] = max(abs(C1));
SampleDiff = lag1(I)
timeDiff = SampleDiff/Fs
% -> minimal time difference!! facet is only 21 samples / 0.0026s ahead
% also via finddeley(T1, T2)

% calculate pearson correlation between uncorrected signals
r = corrcoef(T1, T2); % r = 0.8

% correct the (minimal) timelag
T1_cor = alignsignals(T1, T2);
r_cor = corrcoef(T1_cor, T2) % immernoch r = 0.8


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

[rmax, rmax_ind] = min(r_alg);
[rmin, rmin_ind] = min(r_alg);
[rzero, rzero_ind] = min(abs(r_alg)); % the same as rmin - problem trial?

S_fac = dat.trial{rmax_ind}(2,:);
S_emg = dat.trial{rmax_ind}(3,:);
Fs = 128;

[C1,lag1] = xcorr(S_fac,S_emg);

figure
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