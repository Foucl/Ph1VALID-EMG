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



function [ ga ] = aggregateTimelocks (experiment, SessionInfo, force, forceGA)

em = {'AN', 'HA'};
valid = {'val', 'inval'};
musc = {'cor', 'zyg'};
l = 1;
for i = 1:length(em)
    for j = 1: length(valid)
        for k = 1: length(musc)
            baseCons{l} = [em{i} '_' valid{j} '_' musc{k}];
            l = l +1;
        end;
    end;
end;
c = cell(8,1);
TlCondTemplate = struct('Rp', cell2struct(c, baseCons), 'Ts', cell2struct(c, baseCons));

if strcmpi(experiment, 'both')
    exp = {'Rp', 'Ts'};
else
    exp{1} = experiment;
end;

for k = 1:length(exp)
    ga_file = fullfile(SessionInfo.outDir, ['tlga_' exp{k} '.mat']);
    if exist(ga_file,'file') && ~forceGA
        gaCur = load(ga_file);
        ga.(exp{k}) = gaCur.ga.(exp{k});
        %TlCond = nan;
        continue;
    end;
    
    %% read individual timelocks
clear TlCond;    
TlCond.(exp{k}) = TlCondTemplate.(exp{k});
    fehler = cell(46,1);
    j = 1;
    tic;
    for i = 1:46
        if i < 10
            b = ['0' num2str(i)];
        else
            b = num2str(i);
        end;
        arg = ['VP' b];
        try
            TlCond(i) = ph1valid04_timelockSubject (exp{k}, arg, force);
         catch ME
             disp(ME);
             fehler{j} = sprintf('%s: %s', arg, ME.message);
             j = j + 1;
         end;
    end
    toc
    fehler = fehler(~cellfun('isempty',fehler));
    disp(fehler);
    TlCondCur = [TlCond.(exp{k})];
    empty_elems = arrayfun(@(s) all(structfun(@isempty,s)), TlCondCur);
    TlCond(empty_elems) = [];
    TlCondCur(empty_elems) = [];
    
    %% calculate grand averaged timelock for each condition
    conds = fieldnames(TlCondCur);
    for i = 1:length(conds)
        con = conds{i};
        %TlCondCur = TlCond.(exp{k});
        tl = {TlCondCur(:).(con)};
        cfg = [];
        cfg.parameter = 'avg';
        ga.(exp{k}).(con) = ft_timelockgrandaverage(cfg, tl{:});
    end;
    
    save(ga_file, 'ga');
end;
