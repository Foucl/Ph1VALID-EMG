function [ SessionInfo ] = ph1valid00_setup( force )
%PH1VALID_SETUP Sets up directory information and stores them in 'SessionInfo'
% as well as in the global Variable 'Sess'
% also loads fieldtrip

if nargin < 1
    force = false;
end;

%% check if setup was already run
global Sess;
    
if ~isempty(Sess) && ~force
    SessionInfo = Sess;
    return;
else
    clear Sess; 
end;

%% deactivate annoying warnings

warning('off', 'MATLAB:dispatcher:pathWarning');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
% restoredefaultpath;


S.userDir = char(java.lang.System.getProperty('user.home'));
S.userName = char(java.lang.System.getProperty('user.name'));
S.computerName = char(java.net.InetAddress.getLocalHost.getHostName);

S.localDataDirExists = false;

localDataPath = fullfile(S.userDir, 'ph1valid_data');
localOutPath = fullfile(S.userDir, 'ph1valid_out');
localToolboxPath = fullfile(S.userDir, 'Matlab-toolboxes');

if exist(localDataPath, 'dir')
    S.localDataDirExists = true;
    mkdir(localOutPath)
end

S.dataDir = [];
S.outDir = [];

if ~exist(localToolboxPath, 'dir')
        error(['could not find ' localToolboxPath]);
elseif ~exist(localDataPath, 'dir')
    error(['could not find ' localDataPath]);
else
    S.toolboxDir = localToolboxPath;
    S.dataDir = localDataPath;
    S.outDir = localOutPath;
end

S.emgRawDir = fullfile(S.dataDir, 'EMG_raw');
S.presentationDir = fullfile(S.dataDir, 'Presentation-logfiles');
S.emgPreproDir = fullfile(S.outDir, 'EMG_preprocessed');
S.emgDsDir = fullfile(S.outDir, 'EMG_downsampled');
S.emgRawDir = S.emgDsDir;
S.subjmfileDir = fullfile(S.outDir, 'subjmfiles');

[S.projectDir, ~, ~] = fileparts(mfilename('fullpath'));
[S.projectBaseDir, ~, ~] = fileparts(S.projectDir);

addpath(fullfile(S.subjmfileDir));
addpath(genpath(fullfile(S.projectDir)));
addpath(fullfile(S.toolboxDir, 'fieldtrip'));
addpath(fullfile(S.toolboxDir, 'fieldtrip', 'fileio'));

global Sess;
Sess = S;

SessionInfo = S;
end