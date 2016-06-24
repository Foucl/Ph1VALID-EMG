function [trl, event] = trialfun_ph1valid_Rp(cfg)

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
hdr        = ft_read_header(cfg.dataset);
event      = ft_read_event(cfg.dataset);

trl = [];
val = [];
sel = true(1, length(event));
for i=1:numel(event)
    sel(i) = sel(i) && ismatch(event(i).type, 'STATUS');
end
for i=1:numel(event)
    sel(i) = sel(i) && ismatch(event(i).value, [51 52 62 61]);
end
sel = find(sel);

for i=sel
  % catch empty fields in the event table and interpret them meaningfully
  if isempty(event(i).offset)
    % time axis has no offset relative to the event
    event(i).offset = 0;
  end
  if isempty(event(i).duration)
    % the event does not specify a duration
    event(i).duration = 0;
  end
  % determine where the trial starts with respect to the event
  
    % override the offset of the event
    trloff = round(-cfg.trialdef.prestim*hdr.Fs);
    % also shift the begin sample with the specified amount
    trlbeg = event(i).sample + trloff;
    trldur = round((cfg.trialdef.poststim+cfg.trialdef.prestim)*hdr.Fs) - 1;

  trlend = trlbeg + trldur;
  % add the beginsample, endsample and offset of this trial to the list
  % if all samples are in the dataset
  if trlbeg>0 && trlend<=hdr.nSamples*hdr.nTrials,
    trl = [trl; [trlbeg trlend trloff]];
    if isnumeric(event(i).value),
      val = [val; event(i).value];
    else
      val = [val; nan];
    end
  end
end

% append the vector with values
if ~isempty(val) && ~all(isnan(val)) && size(trl,1)==size(val,1)
  trl = [trl val];
end

if length(trl) < 190
    %if isempty(strfind(cfg.dataset, 'VP14'))
        nTrl = length(trl);
        error(['custom:less_' int2str(nTrl)], 'not enough trials, found only %d.', nTrl);
  %  end;
elseif length(trl) > 210
    nTrl = length(trl);
    trl = trl(length(trl) - 200 + 1:end,:);
    warning(['custom:more_' int2str(nTrl)], 'too many trials. found %d.\nTrimming away early trials.', nTrl);
else
    nTrl = length(trl);
end;

end % function


function s = ismatch(x, y)
if isempty(x) || isempty(y)
  s = false;
elseif ischar(x) && ischar(y)
  s = strcmp(x, y);
elseif isnumeric(x) && isnumeric(y)
  s = ismember(x, y);
elseif ischar(x) && iscell(y)
  y = y(strcmp(class(x), cellfun(@class, y, 'UniformOutput', false)));
  s = ismember(x, y);
elseif isnumeric(x) && iscell(y) && all(cellfun(@isnumeric, y))
  s = false;
  for i=1:numel(y)
    s = s || ismember(x, y{i});
  end
else
  s = false;
end
end