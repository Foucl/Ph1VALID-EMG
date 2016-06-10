function [ output_args ] = ph1valid01_prepro( input_args )
%PH1VALID01_PREPRO Summary of this function goes here
%   Detailed explanation goes here

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;

end

