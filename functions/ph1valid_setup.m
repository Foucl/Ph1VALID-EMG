function [ SessionInfo ] = ph1valid_setup( context )
%PH1VALID_SETUP Summary of this function goes here
%   Detailed explanation goes here

if nargin < 1
    context = 'local';
end;

warning('off', 'MATLAB:dispatcher:pathWarning');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
restoredefaultpath;

% get basic information on current machine

SERVER_DRIVE = 'O:';

% alternatively use v2struct(a,b,c) to add vars to strucutre later
S.userDir = char(java.lang.System.getProperty('user.home'));
S.userName = char(java.lang.System.getProperty('user.name'));
S.computerName = char(java.net.InetAddress.getLocalHost.getHostName);

S.serverConnected = false;
S.localDataDirExists = false;

remoteDataPath = fullfile(SERVER_DRIVE,'Mitarbeiter','Christopher','Data_ValidExp');
remoteOutPath = fullfile(SERVER_DRIVE,'Mitarbeiter','Christopher','Analysis_ValidExp','ph1valid_out');
remoteToolboxPath = fullfile(SERVER_DRIVE, 'Mitarbeiter', 'Christopher', 'Tools', 'Matlab-toolboxes');


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

addpath(fullfile(S.toolboxDir, 'fieldtrip'));

%experimental: use global variable, so the setup does not have to be run
%every time:
global Sess;
Sess = S;

SessionInfo = S;
end

