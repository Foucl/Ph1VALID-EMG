%% Attempts to account for observer + subject effects [would need more than 1 subj!]

% dat_c: 1: JoyConf, 2: AngConf, 3: Cor, 4: Zyg

fac_ang = dat_c.trial{1}(2,:);
emg_ang = dat_c.trial{1}(3,:);

corrcoef(fac_ang, emg_ang);

concatMat = [fac_ang; emg_ang];

csvwrite('VP46.csv', concatMat);