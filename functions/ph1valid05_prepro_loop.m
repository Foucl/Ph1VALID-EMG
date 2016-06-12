j = 1;
for i = 1:46
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end
    
    try
        ph1valid01_prepro(['VP' b])
    catch ME
        disp(ME);
        fehler{j,1} = ['VP' b];
        fehler{j,2} = ME.message;
        j = j + 1;
    end;
end

