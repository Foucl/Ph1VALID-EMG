function ph1valid05_prepro_loop_TS( type )

%SessionInfo = ph1valid_setup;

if nargin < 1
    type = 'both';
end;


j = 1;
tic;
fehler = cell(46,1);
for i = 1:46
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end;
    arg = ['VP' b];
    try
        switch type
            case 'prepro'
                ph1valid01_prepro_TS(arg);
            case 'class'
                ph1valid02_classify_TS('subjid', arg, 'which_th', 'cleanThreshold');
            case 'both'
                ph1valid01_prepro_TS(arg);
                ph1valid02_classify_TS('subjid', arg, 'which_th', 'cleanThreshold');
        end;
    catch ME
       % disp(ME);
        fehler{j} = sprintf('%s: %s', arg, ME.message);
        j = j + 1;
    end;
end
toc
fehler = fehler(~cellfun('isempty',fehler));
disp(fehler)