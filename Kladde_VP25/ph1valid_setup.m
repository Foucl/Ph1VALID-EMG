%% setup

restoredefaultpath;

%get home path
userDir = char(java.lang.System.getProperty('user.home'));

%get connection state

localDataDir = fullfile(userDir, 'ph1valid_data');
remoteDataDir = 'O:\Mitarbeiter\Christopher\Data_ValidExp';
remoteTb = 'O:/Mitarbeiter/Christopher/Tools/Matlab-toolboxes';
localTb = fullfile(userDir,  'Matlab-toolboxes');

% setup paths
toolboxes_path = localTb;
data_path = localDataDir;
emg_path = fullfile(data_path, 'EMG_raw');
presentation_path = fullfile(data_path, 'Presentation-logfiles');

% remove existing eeglab & fieldtrip installations from path


% add my git clones of eeglab and fieldtrip to path
addpath(fullfile(toolboxes_path, 'fieldtrip'));
addpath(fullfile(toolboxes_path, 'fieldtrip', 'fileio')); %TODO parametrize that
addpath(fullfile(toolboxes_path, 'eeglab'));