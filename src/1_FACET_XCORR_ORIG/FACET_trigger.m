function [T] = FACET_trigger(subjid, file, subjinfoDir, outputDir)
%FACET_trigger recode Switching triggers use ',' as dec. seperator
%
%   inputs:
%   - subjid (z.B. 'VP07')
%   - file (z.B. 'C:\irgendein\ordner\Dump036_VP36.txt'
%   - subjinfoDir: Ordner, in dem subjinfo-mfiles liegen (VP##_subjinfo.m)
%                  (z.B. 'C:\irgendein\anderer\ordner')
%   - outputDir: Ordner, in dem die csv-Datei gespeichert wird
%                  (z.B. 'C:\noch\ein\ordner')
%
%
%   returns:
%   - T: Tabelle mit korrekt umkodierten Triggern des Switching
%        Experiments (das Dezimaltrennzeichen der numerischen Werte ist
%        ein Punkt, da Matlab hier kein Komma verstehen w¸rde)
%
%   schreibt auﬂerdem eine csv-Datei ins aktuelle working directory, in der
%   das Dezimaltrennzeichen ein Komma ist (diese Datei hat den gleichen
%   Namen wie der FACET-Datensatz). In dieser Datei sind allerdings
%   notwendigerweise die Strings nicht mit Anf¸hrungszeichen umgeben.
%
% auf meinem Rechner f¸hre ich diese Funktion z.B. so aus:
% subjid = 'VP38';
% file = 'C:\Users\DDmitarbeiter\cd\Ph1VALID-EMG\data\raw\FACET\Dump036_VP36.txt';
% subjinfoDir = 'C:\Users\DDmitarbeiter\cd\Ph1VALID-EMG\data\processed\subjmfiles';
% outputDir = 'C:\Users\DDmitarbeiter\cd\Ph1VALID-EMG\data\processed\FACET_csvs';
%T = FACET_trigger(subjid, file, subjinfoDir, outputDir);

%% setup

addpath(subjinfoDir);

%% Entfernung der Header, einlesen des der Variablennamen

% ˆffne die Datei
fid = fopen(file, 'r');

% Lese die Headerline (mit den Variablennamen) als langen String
% (¸berspringe dabei die ersten 6 Zeilen)
label = textscan(fid, '%[^\n]', 1, 'delimiter', '\t', 'HeaderLines', 6);

% Splitte den String in die einzelnen Variablennamen, so dass man ein
% sauberes Cell Array erh‰lt
label = textscan(label{1}{1}, '%[^\t]');
label = label{1};

% jeder weitere textscan der fid ¸berspringt alles, was schon eingelesen
% wurde

%% Kompletten Datensatz einlesen (dabei auf Variablen-Typen achten!)

% Bis zur Variable 'EventSource' kˆnnen alle Variablen als Strings
% interpretiert werden:
tmp = strfind(label,'EventSource');
indEventsource = find(not(cellfun('isempty', tmp)));
strBeginn = ['%s%{yyyyMMdd}D' repmat('%s', [1 indEventsource-2])];

% Die Variablen zw. Timestamp & LiveMarker sind die numerischen Daten
tmp = strfind(label,'LiveMarker');
indLivemarker = find(not(cellfun('isempty', tmp)));
strMitte = repmat('%f', [1 (indLivemarker - indEventsource -1)]);

% die letzten Variablen-Typen f¸hre ich von Hand an: 2 Strings, ein Integer
% (der Trigger selbst) und drei Strings

strEnde = '%s%s%f%s%s%s';

% nun kompletten Datensatz einlesen
str = [strBeginn strMitte strEnde];
dataCellArray = textscan(fid, str, 'Delimiter', '\t');
fclose(fid);

%% Trigger korrigieren

tmp = strfind(label,'MarkerText');
indTrigger = find(not(cellfun('isempty', tmp)));

% Trigger in Array lesen:
trg = (dataCellArray{indTrigger});

% happy_letter einlesen und pr¸fen, um umkodiert werden muss:
eval([subjid '_subjinfo']); % -> l‰dt eine Reihe von Informationen ¸ber die VP in die Variable 'subjinfo'

happy_trgs = [241 242 251:253];
angry_trgs = happy_trgs - 100;

if strcmpi(subjinfo.happy_letter, 'm') % umkodieren immer dann, wenn der happy_letter m ist
    % geht sicher auch eleganter, aber ich loope jetzt einfach ¸ber jedes
    % Element des Trigger-Arrays:
    for i = 1:numel(trg)
        if ismember(trg(i), happy_trgs) % falscher Freude-Trial -> 100 abziehen
            trg(i) = trg(i) - 100;
        elseif ismember(trg(i), angry_trgs) % vice versa
            trg(i) = trg(i) + 100;
        end;
    end;
end;
dataCellArray{indTrigger} = trg;

%% nun datensatz in Tabelle ¸berf¸hren (zwecks Export)

%Variablennamen mit Leerzeichen funktionieren in Matlab nicht:
label = cellfun(@(x) strrep(x, ' ', '_'), label, 'Uniform', 0);

T = cell2table(dataCellArray, 'VariableNames', label);

% 'expandieren' der Zellen in der Tablle
T = varfun(@(x) x{1}, T);

% varfun hinterl‰sst h‰ssliches 'Fun_' am Anfang der Variablennamen
varnames = T.Properties.VariableNames;
varnames = cellfun(@(x) x(5:end), varnames, 'Uniform', 0);
T.Properties.VariableNames = varnames;

%% Umwandlung des Dezimaltrennzeichens
% dazu m¸ssen alle numerischen Werte in Strings umgewandelt werden (Matlab
% kennt an sich kein Komma als Dezimaltrennzeichen)

T_export = T;

% extrem ineffizenter loop (if/else in anonymen Funktionen nicht mˆglich)
% -> Geduld haben
for i = 1:numel(varnames)
    curvar = T_export.(varnames{i});
    if isnumeric(curvar)
        curvar = cellfun(@num2str, num2cell(curvar), 'UniformOutput', false);
        curvar = cellfun(@(x) strrep(x, '.', ','), curvar, 'Uniform', 0);
    end;
    T_export.(varnames{i}) = curvar;
end;
 
% die neue Tabelle mit fast ausschlieﬂlich Strings bringt Matlab auch an
% ihre Grenzen - auch beim Export ist ewtas Geduld angesagt
[~, name, ~] = fileparts(file);
writetable(T_export, fullfile(outputDir, [name '.csv']), 'QuoteStrings', 0);

