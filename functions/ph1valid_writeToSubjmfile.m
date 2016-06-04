function [ output_args ] = ph1valid_writeToSubjmfile( SubjInfo )
%PH1VALID_WRITETOSUBJMFILE Summary of this function goes here
%   Detailed explanation goes here

% takes a one-level structure and writes (appends) all fields as variables
% to subjmfile

% checks if subjmfile already exists and, if not, asks whether or not to
% create it (from presentation-file)

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;
subjmfileDir = SessionInfo.subjmfileDir;


for i = 1:length(SubjInfo)
    %write to file
    fname =  [SubjInfo(i).subjid '_subjinfo.m'];
    fid = fopen(fullfile(subjmfileDir, fname),'At', 'n', 'ISO-8859-1'); % A: append without automatic flushing, t: open file in text mode
    fprintf(fid,'%s\n\n',['%%% Subjmfile of ' SubjInfo(i).subjid ', created at @ ' datestr(now)]); % write date and time
    
    fieldNames = fieldnames(SubjInfo(i));
     for iField = 1:length(fieldNames)
         var = fieldNames{iField};
         val = SubjInfo(i).(fieldNames{iField});
         if isnumeric(val)
             val = int2str(val);
         else
             val = ['''' val ''''];
         end;
         fprintf(fid, '%s = %s;\n', var, val);
     end
    
    fclose all;
end;


end

