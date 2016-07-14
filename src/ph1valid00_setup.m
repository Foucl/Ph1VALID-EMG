function [ SessionInfo ] = ph1valid00_setup( )
%PH1VALID_SETUP Sets up directory information and stores them in 'SessionInfo'
% as well as in the global Variable 'Sess'
% also loads fieldtrip

[S.srcDir, ~, ~] = fileparts(mfilename('fullpath'));
[S.projectBaseDir, ~, ~] = fileparts(S.srcDir);

userDir = char(java.lang.System.getProperty('user.home'));


if nargin < 1
    force = false;
end;

%% deactivate annoying warnings

warning('off', 'MATLAB:dispatcher:pathWarning');
warning('off', 'MATLAB:MKDIR:DirectoryExists');
% restoredefaultpath;

S.toolboxDir = fullfile(S.projectBaseDir, 'src', '.external');
S.dataDir = fullfile(S.projectBaseDir, 'data');
%S.emgRawDir = fullfile(S.dataDir, 'raw', 'EMG_raw');
S.emgDsDir = fullfile(S.dataDir, 'interim', 'EMG_downsampled');
S.emgRawDir = S.emgDsDir;
S.emgPreproDir = fullfile(S.dataDir, 'preprocessed', 'EMG_preprocessed');
S.subjmfileDir = fullfile(S.dataDir, 'processed', 'subjmfiles');
S.tableDir = fullfile(S.dataDir, 'processed', 'tables');
S.figDir = fullfile(S.projectBaseDir, 'reports', 'figures');

if ~exist(fullfile(S.toolboxDir, 'fieldtrip'), 'dir')
    S.toolboxDir = fullfile(userDir, 'matlab-toolboxes');
end;

addpath(fullfile(S.toolboxDir, 'fieldtrip'));

try
    ft_defaults
catch ME
    error('error: fieldtrip not found')
end;

addpath(fullfile(S.subjmfileDir));
%addpath(genpath(fullfile(S.projectDir)));
addpath(S.srcDir);
addpath(genpath((fullfile(S.srcDir, 'pipeline'))));

SessionInfo = S;
end