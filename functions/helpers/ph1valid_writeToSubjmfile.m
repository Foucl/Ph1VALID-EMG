function [ output_args ] = ph1valid_writeToSubjmfile( SubjInfo, subjid )
%PH1VALID_WRITETOSUBJMFILE write to subject mfile
%   takes a one-level structure and writes (appends) all fields as
%   variables to subjmfile
%   checks if subjmfile already exists and, if not, asks whether or not to
%   create it (from presentation-file)

SessionInfo = ph1valid_setup;

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
    
    cleanSubjmfile(SubjInfo(i), fullfile(subjmfileDir, fname));
    
    fid = fopen(fullfile(subjmfileDir, fname),'At', 'n', 'ISO-8859-1'); % A: append without automatic flushing, t: open file in text mode
    %fprintf(fid,'\n%s\n\n',['%%% Subjmfile of ' sid ', this section was created at @ ' datestr(now)]); % write date and time
    
    fieldNames = fieldnames(SubjInfo(i));
     for iField = 1:length(fieldNames)
         var = ['subjinfo.' fieldNames{iField}];
         val = SubjInfo(i).(fieldNames{iField});
         if isnumeric(val)
             val = num2str(val(:)');
             val = sprintf('[ %s ]', val);
             if isempty(val)
                 val = '[]';
             end;
         elseif isdatetime(val)
             val = datestr(val);
             val = ['''' val ''''];
         else
             val = ['''' val ''''];
         end;
         fprintf(fid, '%s = %s;\n', var, val);
     end
    
    fclose all;
end;


function cleanSubjmfile (SubjInfo, fname)
fieldNames = fieldnames(SubjInfo);
vars = [];

try
    fid = fopen(fname,'r', 'n', 'ISO-8859-1');
    Data = textscan(fid, '%s', 'delimiter', '\n', 'whitespace', '');
    CStr = Data{1};
    fclose(fid);
    % now in CStr: cell array of all lines in file'

    for iField = 1:length(fieldNames)
        vars{iField} = ['subjinfo.' fieldNames{iField}];
        IndexC = strfind(CStr, vars{iField});
        Index = find(~cellfun('isempty', IndexC), 1);

        if ~isempty(Index)
            CStr(Index) = [];
        end
    end;
    fid = fopen(fname,'w', 'n', 'ISO-8859-1');
    fprintf(fid, '%s\n', CStr{:});
    fclose(fid);
catch
end;





