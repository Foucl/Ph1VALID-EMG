function [ output_args ] = ph1valid_writeToSubjmfile( SubjInfo, subjid )
%PH1VALID_WRITETOSUBJMFILE write to subject mfile
%   takes a one-level structure and writes (appends) all fields as
%   variables to subjmfile
%   checks if subjmfile already exists and, if not, asks whether or not to
%   create it (from presentation-file)

global Sess;
    
if ~isempty(Sess);
    SessionInfo = Sess;
else %setup has not yet been called
    clear Sess;
    SessionInfo = ph1valid_setup;
end;
subjmfileDir = SessionInfo.subjmfileDir;
mult = false;
if nargin < 2
    mult = true;
    subjid = vertcat(SubjInfo.subjid);
end;

for i = 1:length(SubjInfo)
    %write to file
    if mult
        sid = subjid(i,:);
    else
        sid = subjid;
    end;
    fname =  [sid '_subjinfo.m'];
    fid = fopen(fullfile(subjmfileDir, fname),'At', 'n', 'ISO-8859-1'); % A: append without automatic flushing, t: open file in text mode
    fprintf(fid,'\n%s\n\n',['%%% Subjmfile of ' sid ', this section was created at @ ' datestr(now)]); % write date and time
    
    fieldNames = fieldnames(SubjInfo(i));
     for iField = 1:length(fieldNames)
         var = ['subjinfo.' fieldNames{iField}];
         val = SubjInfo(i).(fieldNames{iField});
         if isnumeric(val)
             val = num2str(val);
             val = ['[' val ']'];
             if isempty(val)
                 val = '[]';
             end;
         else
             val = ['''' val ''''];
         end;
         fprintf(fid, '%s = %s;\n', var, val);
     end
    
    fclose all;
end;


end

