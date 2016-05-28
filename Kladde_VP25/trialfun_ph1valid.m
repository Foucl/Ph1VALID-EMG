function [trl, event] = trialfun_ph1valid(cfg)

%% the first part is common to all trial functions
% read the header (needed for the samping rate) and the events
hdr        = ft_read_header(cfg.headerfile);
event      = ft_read_event(cfg.headerfile);

%% from here on it becomes specific to the experiment and the data format
% for the events of interest, find the sample numbers (these are integers)
% for the events of interest, find the trigger values (these are strings in the case of BrainVision)
EVsample   = [event.sample]';
EVvalue    = {event.value}';
trig  = [event.value];
indx  = [event.sample];

% select the target stimuli
trg_AN = [find(trig==51) :find(trig==61)];
trg_HA = [find(trig==52) :find(trig==62)];
trg_prep = [find(trig==52) :find(trig==51)];
trg_unprep = [find(trig==62) :find(trig==61)];
trg_AN_prep = [find(trig==51)];
trg_AN_unprep = [find(trig==61)];
trg_HA_prep = [find(trig==52)];
trg_HA_unprep = [find(trig==62)];

% -500 .. +3500 ms
PreTrig   = round(0.5 * hdr.Fs);
PostTrig  = round(3.5 * hdr.Fs);

begsample = indx(trg_AN_prep) - PreTrig;
endsample = indx(trg_AN_prep) + PostTrig;

offset = -PreTrig*ones(size(endsample));

%% the last part is again common to all trial functions
% return the trl matrix (required) and the event structure (optional)
trl = [begsample endsample offset task];

end % function