function [ mfile_table ] = ph1valid_aggregate_mfiles( input_args )
%PH1VALID_AGGREGATE_MFILES Summary of this function goes here
%   Detailed explanation goes here
global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

subjmfileDir = SessionInfo.subjmfileDir;

existingSubjmfiles = ls(subjmfileDir);
existingSubjmfiles = existingSubjmfiles(3:end,1:end-2);


for i = 1:length(existingSubjmfiles)
    eval(existingSubjmfiles(i,:));
    sub(i) = subjinfo;
end;

mfile_table = struct2table(sub);
writetable(mfile_table, 'subjinfo.csv');
end

