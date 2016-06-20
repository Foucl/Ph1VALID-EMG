high level descriptions of what the functions/parts should do
keep in mind:
- many arguments (>3) -> structures
- subfunction: when func only called by one function
- write doc header first
- naming: 1 output -> name for output; 0 output -> name for what they do;
- useful keywords (to be reserved): get, set, compute, find, initialize, is
- modularize input and output:
  - read and write subjmfiles: obvious
  - read \*.bdf without any substantial preprocessing? (like neutask-artf)
  - write matlab-files for ft-objects?

## setup
#### takes in
- (opt) `kontext`: präferenz für lokal vs remote
#### returns
- `data_path`: parent folder of EMG_raw and presentation-logs
- `out_path`: parent folder of EMG_preprocessed, subjmfiles (and more to come)
- (opt) `emg_raw_path`
- (opt) `emg_pp_path`
- (opt) `subjm_path`
#### takes care of
- searchpath (toolboxes)



## prepro
#### takes in
- `subjid`. default: VP09
- `segment`: `[pre .. post]`. default: `[2 2.5]`
- `baseline_period`: `[begin .. end]`. default: `[-2 -1.8]`

#### returns
a lot of info on the subject:
- ft-data-object itself
- how many trials per con? making sense?
-

#### takes care of
- subjmfile: a lot of info written to it
- keep short!! should only do one-and-a-half thing: read bdf-file, segment according to RP-trials, and do some basic preprocessing:
  - filtering
  - baseline-correction
  - rectification
  - resampling??


## update/read-presentation-subjfiles
#### takes in
- data_path & out_path?
- optionally: array of subjids to use (will this overwrite?)
#### returns
- list of created subjmfiles
- list of existing subjmfiles
#### does
- call a subfunction in a loop, with this subfunction doing (given a subjid):
  - find data_path/presentation-logfiles/subjid/\*\_subjinfo.tsv
  - parse it as a tsv,
