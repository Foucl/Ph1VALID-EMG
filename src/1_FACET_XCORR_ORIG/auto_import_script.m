%% Import data from text file.
% Script for importing data from the following text file:
%
%    C:\Users\DDmitarbeiter\ph1valid_data\FACET\Dump046_VP46.txt
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2016/06/24 20:47:42

%% Initialize variables.
filename = 'C:\Users\DDmitarbeiter\ph1valid_data\FACET\Dump046_VP46.txt';
delimiter = '\t';
startRow = 7;

%% Read columns of data as strings:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
textscan(fileID, '%[^\n\r]', startRow-1, 'WhiteSpace', '', 'ReturnOnError', false);
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'ReturnOnError', false);

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric strings to numbers.
% Replace non-numeric strings with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[3,4,9,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59]
    % Converts strings in the input cell array to numbers. Replaced non-numeric
    % strings with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric strings to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

% Convert the contents of columns with dates to MATLAB datetimes using date
% format string.
try
    dates{2} = datetime(dataArray{2}, 'Format', 'dd-MMM-yyyy HH:mm:ss', 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
catch
    try
        % Handle dates surrounded by quotes
        dataArray{2} = cellfun(@(x) x(2:end-1), dataArray{2}, 'UniformOutput', false);
        dates{2} = datetime(dataArray{2}, 'Format', 'dd-MMM-yyyy HH:mm:ss', 'InputFormat', 'dd-MMM-yyyy HH:mm:ss');
    catch
        dates{2} = repmat(datetime([NaN NaN NaN]), size(dataArray{2}));
    end
end

anyBlankDates = cellfun(@isempty, dataArray{2});
anyInvalidDates = isnan(dates{2}.Hour) - anyBlankDates;
dates = dates(:,2);

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [3,4,9,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59]);
rawCellColumns = raw(:, [1,5,6,7,8,10,11,12,60,61,62,63,64,65]);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
StudyName = rawCellColumns(:, 1);
ExportDate = dates{:, 1};
Name = cell2mat(rawNumericColumns(:, 1));
Age = cell2mat(rawNumericColumns(:, 2));
Gender = rawCellColumns(:, 2);
StimulusName = rawCellColumns(:, 3);
SlideType = rawCellColumns(:, 4);
EventSource = rawCellColumns(:, 5);
Timestamp = cell2mat(rawNumericColumns(:, 3));
MediaTime = rawCellColumns(:, 6);
PostMarker = rawCellColumns(:, 7);
Annotation = rawCellColumns(:, 8);
FrameNo = cell2mat(rawNumericColumns(:, 4));
FrameTime = cell2mat(rawNumericColumns(:, 5));
NoOfFaces = cell2mat(rawNumericColumns(:, 6));
FaceRectX = cell2mat(rawNumericColumns(:, 7));
FaceRectY = cell2mat(rawNumericColumns(:, 8));
FaceRectWidth = cell2mat(rawNumericColumns(:, 9));
FaceRectHeight = cell2mat(rawNumericColumns(:, 10));
JoyEvidence = cell2mat(rawNumericColumns(:, 11));
JoyIntensity = cell2mat(rawNumericColumns(:, 12));
AngerEvidence = cell2mat(rawNumericColumns(:, 13));
AngerIntensity = cell2mat(rawNumericColumns(:, 14));
SurpriseEvidence = cell2mat(rawNumericColumns(:, 15));
SurpriseIntensity = cell2mat(rawNumericColumns(:, 16));
FearEvidence = cell2mat(rawNumericColumns(:, 17));
FearIntensity = cell2mat(rawNumericColumns(:, 18));
ContemptEvidence = cell2mat(rawNumericColumns(:, 19));
ContemptIntensity = cell2mat(rawNumericColumns(:, 20));
DisgustEvidence = cell2mat(rawNumericColumns(:, 21));
DisgustIntensity = cell2mat(rawNumericColumns(:, 22));
SadnessEvidence = cell2mat(rawNumericColumns(:, 23));
SadnessIntensity = cell2mat(rawNumericColumns(:, 24));
NeutralEvidence = cell2mat(rawNumericColumns(:, 25));
NeutralIntensity = cell2mat(rawNumericColumns(:, 26));
PositiveEvidence = cell2mat(rawNumericColumns(:, 27));
PositiveIntensity = cell2mat(rawNumericColumns(:, 28));
NegativeEvidence = cell2mat(rawNumericColumns(:, 29));
NegativeIntensity = cell2mat(rawNumericColumns(:, 30));
AU1Evidence = cell2mat(rawNumericColumns(:, 31));
AU2Evidence = cell2mat(rawNumericColumns(:, 32));
AU4Evidence = cell2mat(rawNumericColumns(:, 33));
AU5Evidence = cell2mat(rawNumericColumns(:, 34));
AU6Evidence = cell2mat(rawNumericColumns(:, 35));
AU7Evidence = cell2mat(rawNumericColumns(:, 36));
AU9Evidence = cell2mat(rawNumericColumns(:, 37));
AU10Evidence = cell2mat(rawNumericColumns(:, 38));
AU12Evidence = cell2mat(rawNumericColumns(:, 39));
AU14Evidence = cell2mat(rawNumericColumns(:, 40));
AU15Evidence = cell2mat(rawNumericColumns(:, 41));
AU17Evidence = cell2mat(rawNumericColumns(:, 42));
AU18Evidence = cell2mat(rawNumericColumns(:, 43));
AU20Evidence = cell2mat(rawNumericColumns(:, 44));
AU23Evidence = cell2mat(rawNumericColumns(:, 45));
AU24Evidence = cell2mat(rawNumericColumns(:, 46));
AU25Evidence = cell2mat(rawNumericColumns(:, 47));
AU26Evidence = cell2mat(rawNumericColumns(:, 48));
AU28Evidence = cell2mat(rawNumericColumns(:, 49));
AU43Evidence = cell2mat(rawNumericColumns(:, 50));
LiveMarker = rawCellColumns(:, 9);
KeyStroke = rawCellColumns(:, 10);
MarkerText = rawCellColumns(:, 11);
SceneType = rawCellColumns(:, 12);
SceneOutput = rawCellColumns(:, 13);
SceneParent = rawCellColumns(:, 14);

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% ExportDate=datenum(ExportDate);


%% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans raw col numericData rawData row regexstr result numbers invalidThousandsSeparator thousandsRegExp me dates blankDates anyBlankDates invalidDates anyInvalidDates rawNumericColumns rawCellColumns R;