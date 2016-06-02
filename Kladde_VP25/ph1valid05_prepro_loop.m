for i = 9:30
    if i < 10
        b = ['0' num2str(i)];
    else
        b = num2str(i);
    end
    ph1valid01_prepro(['VP' b])
end

