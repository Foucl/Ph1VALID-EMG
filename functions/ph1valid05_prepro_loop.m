function ph1valid05_prepro_loop( type )

funs = {'ph1valid01_prepro', 'ph1valid02_classify'};

SessionInfo = ph1valid_setup;

if nargin < 1
    type = 'both';
end;

fehler = [];
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
        switch type
            case 'prepro'
                ph1valid01_prepro(arg);
            case 'class'
                ph1valid02_classify(arg);
            case 'both'
                ph1valid01_prepro(arg);
                ph1valid02_classify(arg);
        end;
    catch ME
        disp(ME);
        fehler{j,1} = ['VP' b];
        fehler{j,2} = ME.message;
        j = j + 1;
    end;
end
toc
disp(fehler)