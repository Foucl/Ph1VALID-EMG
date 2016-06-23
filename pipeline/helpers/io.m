classdef io
    %IO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        function normalizeStructs(existingSubjmfiles)
            
            
            subfields = cell(0,1);
            for i = 1:length(existingSubjmfiles)
                eval(existingSubjmfiles(i,:));
                % concatenate
                subfields = [subfields; fieldnames(subjinfo)];
            end;
            %
            % % find all unique fields
            allfields = unique(subfields);
            %
            % % do another loop and compare fieldnames with allfields, and create array of structs
            for i = 1:length(existingSubjmfiles)
                eval(existingSubjmfiles(i,:));
                % concatenate
                missingFields = setdiff(allfields, fieldnames(subjinfo));
                for j = 1:length(missingFields)
                    subjinfo.(missingFields{j}) = nan;
                end;
                ph1valid_writeToSubjmfile(subjinfo, subjinfo.subjid);
            end;
        end;
        function [ SubjInfo ] = ph1valid_getSubjFiles( force )
            %PH1VALID_GETSUBJFILES read presentation log files
            %   Detailed explanation goes here
            
            isLoop = true;
            
            SessionInfo = ph1valid00_setup;
            
            presentationDir = SessionInfo.presentationDir;
            subjmfileDir = SessionInfo.subjmfileDir;
            
            if nargin < 1
                force = false;
                %subjid = 'VP09';
            end;
            
            % SubjVars = parsePresLog(subjid, presentationDir);
            % SubjInfoTemplate = structfun(@(x) (nan),SubjInfoTemplate, 'UniformOutput',0);
            % save('SubjInfoTemplate.mat', 'SubjInfoTemplate');
            load('SubjInfoTemplate.mat');
            
            if ~isLoop
                SubjVars = io.parsePresLog(subjid, presentationDir, SubjInfoTemplate);
                SubjInfo = SubjVars;
            else %loop over all files
                availablePresFiles = ls(presentationDir);
                availablePresFiles = availablePresFiles(4:end,1:4);
                existingSubjmfiles = ls(subjmfileDir);
                existingSubjmfiles = existingSubjmfiles(3:end,1:end-11);
                if force==false
                    toLoop = setdiff(availablePresFiles, existingSubjmfiles, 'rows');
                else
                    toLoop = availablePresFiles;
                end;
                for i = 1:size(toLoop,1)
                    SubjInfo(i) = io.parsePresLog(toLoop(i,:), presentationDir, SubjInfoTemplate);
                end;
            end;
            
            if ~exist('SubjInfo', 'var')
                warning('All available infofiles already converted - nothing to do');
                return;
            end;
            %now everything is ready inside SubjInfo
            io.writeToSubjmfile(SubjInfo);
            if isLoop
                clear SubjInfo;
            end;
        end
        
        function [ SubjVars ] = parsePresLog ( subjid, path, template )
            % reads subjinfo-file and returns variables in structure SubjVars
            %slCharacterEncoding('ISO-8859-1');
            slCharacterEncoding('Windows-1252');
            presFolder = fullfile(path, subjid);
            FnameObj = dir(fullfile(presFolder, '*subjinfo.tsv'));
            fname = FnameObj.name;
            file = fullfile(presFolder, fname);
            
            s = tdfread(file);
            if isempty(fieldnames(s))
                error(['Problem with subject ' subjid]);
            end
            s = struct2cell(s);
            SubjVars = template;
            SubjVars.subjid = subjid;
            %SubjVars.date = FnameObj.date;   % not working well; better done via
            %biosemi-header
            for i = 1:size(s{1},1)
                var = strtrim(s{1}(i,:));
                val = s{2}(i,:);
                if ~isnumeric(val)
                    val = strtrim(val);
                end;
                if isstrprop(val, 'digit')
                    val = str2num(val);
                elseif strcmpi(val, 'nan')
                    val = nan;
                end;
                SubjVars.(var) = val;
            end;
            return;
        end
        function [ output_args ] = writeToSubjmfile( SubjInfo, subjid )
            %PH1VALID_WRITETOSUBJMFILE write to subject mfile
            %   takes a one-level structure and writes (appends) all fields as
            %   variables to subjmfile
            %   checks if subjmfile already exists and, if not, asks whether or not to
            %   create it (from presentation-file)
            
            SessionInfo = ph1valid00_setup;
            
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
                
                io.cleanSubjmfile(SubjInfo(i), fullfile(subjmfileDir, fname));
                
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
            
        end
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
        end
        
        
    end
    
end

