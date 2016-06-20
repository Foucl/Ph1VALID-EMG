function [ SessionInfo ] = ph1valid_setup( context )
%PH1VALID_SETUP Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    context = 'local';
end;

%% check if setup was already run
global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
    return;
else %setup has not yet been called
    clear Sess; 
end;

%% deactivate annoying warnings

warning('off', 'MATLAB:dispatcher:pathWarning');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
% restoredefaultpath;

% get basic information on current machine

SERVER_DRIVE = 'O:';
SERVER_HOME = fullfile(SERVER_DRIVE, 'Mitarbeiter', 'Christopher');


S.userDir = char(java.lang.System.getProperty('user.home'));
S.userName = char(java.lang.System.getProperty('user.name'));
S.computerName = char(java.net.InetAddress.getLocalHost.getHostName);

S.serverConnected = false;
S.localDataDirExists = false;

remoteDataPath = fullfile(SERVER_HOME,'Data_ValidExp');
remoteOutPath = fullfile(SERVER_HOME,'Analysis_ValidExp','ph1valid_out');
remoteToolboxPath = fullfile(SERVER_HOME, 'Tools', 'Matlab-toolboxes');


localDataPath = fullfile(S.userDir, 'ph1valid_data');
localOutPath = fullfile(S.userDir, 'ph1valid_out');
localToolboxPath = fullfile(S.userDir, 'Matlab-toolboxes');

if exist(remoteDataPath,'dir')
    S.serverConnected = true;
else
    remoteDataPath = nan;
    remoteOutPath = nan;
end;

if exist(localDataPath, 'dir')
    S.localDataDirExists = true;
    mkdir(localOutPath)
end

S.dataDir = [];
S.outDir = [];

if strcmp(context, 'remote') && ~S.serverConnected
    error('requested remote Data, but Network Drive O was not found')
elseif strcmp(context, 'remote') && S.serverConnected
    S.dataDir = remoteDataPath;
    S.outDir = remoteOutPath;
    S.toolboxDir = remoteToolboxPath;
elseif strcmp(context, 'local') && ~exist(localToolboxPath)
    if ~S.ServerConnected
        error('no local toolboxes found and Server not reachable')
    else
        S.toolboxDir = remoteToolboxPath;
    end
elseif strcmp(context, 'local')
    S.toolboxDir = localToolboxPath;
    S.dataDir = localDataPath;
    S.outDir = localOutPath;
end

S.emgRawDir = fullfile(S.dataDir, 'EMG_raw');
S.presentationDir = fullfile(S.dataDir, 'Presentation-logfiles');
S.emgPreproDir = fullfile(S.outDir, 'EMG_preprocessed');
S.subjmfileDir = fullfile(S.outDir, 'subjmfiles');

[S.projectDir, ~, ~] = fileparts(mfilename('fullpath'));
[S.projectBaseDir, ~, ~] = fileparts(S.projectDir);

addpath(fullfile(S.subjmfileDir));
addpath(genpath(fullfile(S.projectDir)));
addpath(fullfile(S.toolboxDir, 'fieldtrip'));
addpath(fullfile(S.toolboxDir, 'fieldtrip', 'fileio'));
addpath(fullfile(S.projectDir, 'helpers'));

global ft_default
ft_default.showcallinfo = 'no';

%experimental: use global variable, so the setup does not have to be run
%every time:
global Sess;
Sess = S;

SessionInfo = S;
end