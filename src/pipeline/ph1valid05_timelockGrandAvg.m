function [ ga, fig ] = ph1valid05_timelockGrandAvg (experiment, forceInd, forceGa)
%% Timelock analysis; returns structure ga, which contains the grand averaged
%% timelocks.

if nargin < 1
    forceInd = false;
    forceGa = false;
    experiment = 'both';
elseif nargin < 2
    forceInd = false;
    forceGa = false;
elseif nargin < 3
    forceGa = false;
end;

SessionInfo = ph1valid00_setup;

%TODO:20 integrate Ts_fine in loop/aggregation
[ ga ]  = aggregateTimelocks (experiment, SessionInfo, forceInd, forceGa);



cfg = [];
cfg.xlim = [-0.1 2.5];
cfg.interactive = 'no';
cfg.linestyle = {'-', '--', '-', '--'};
cfg.graphcolor = 'kkmm';
cfg.linewidth = 0.8;
inner_padding = [0.09, 0.08];
scrsz = get(groot,'ScreenSize');
figure('Name','Reaction Time Grand Average','NumberTitle','off','Position',[1 scrsz(4)/2 scrsz(3)/2 scrsz(4)/2]);


%TODO:50 map exp_long correctly/automatically to experiment

if strcmpi(experiment, 'both')
    exp = {'Rp', 'Ts'};
    exp_long = {'Reponse Priming', 'Response Switching'};
else
    exp{1} = experiment;
    if strcmpi(experiment, 'Rp')
        exp_long{1} = 'Response Priming';
    else
        exp_long{1} = 'Response Switching';
    end;
end;
musc_long = {'Corrugator', 'Zygomaticus major'};

%TODO:30 integrate Ts_fine in plotting
%IDEA: option to compare Rp to either Ts or Ts_fine
k = 1;
for i = 1:length(exp)
    musc = {'cor', 'zyg'};
    for j = 1:length(musc);
        subplot_tight(2,2,k, inner_padding);
        ft_singleplotER(cfg, ga.(exp{i}).(['AN_val_' musc{j}]), ga.(exp{i}).(['AN_inval_' musc{j}]), ga.(exp{i}).(['HA_val_' musc{j}]), ga.(exp{i}).(['HA_inval_' musc{j}]));
        title([exp_long{i} ': ' musc_long{j}]);
        k = k + 1;
    end;
end;

legend1 = legend({'anger valid', 'anger invalid', 'happiness valid', 'happiness valid'}, 'Location', 'NorthEast');

set(legend1,'Position',[0.85 0.33 0.1 0.1]);

tightfig;


fig = gcf;

