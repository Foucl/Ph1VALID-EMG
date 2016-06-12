# Ph1VALID-EMG
UHH ABDD Ph1VALID EMG data analysis with Matlab

## Ressources
### My Gists
- [Gist](https://gist.github.com/Foucl/387b87c8c9aef3daf0c7ab964a5f7832) documenting first attempts at dealing with the data in EEGLAB
- Similar [Gist](https://gist.github.com/Foucl/fb0962cb5b65c84a4dbd6346b54c736c) for fieldtrip

### Other Stuff on EMG analysis
- [fieldtrip tutorial](http://www.fieldtriptoolbox.org/example/detect_the_muscle_activity_in_an_emg_channel_and_use_that_as_trial_definition) for a fancy trialfun that automatically defines trials based on EMG onsets etc.
- [fieldtrip tutorial](http://www.fieldtriptoolbox.org/tutorial/coherence) on corticomuscular coherence
- [sample paper](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC2825576/#R28) (Neta et al., 2010) on facial EMG analysis
- [pdf](http://measuringbehavior.org/files/ProceedingsPDF(website)/Boxtel_Symposium6.4.pdf) on facial EMG
- [NYU PP](www.nyu.edu/classes/mcdonough/signal1.ppt) on EMG Signal Analysis

### Reference papers
- Guillermo: http://onlinelibrary.wiley.com/doi/10.1111/psyp.12220/full

> First, both signals were segmented together in 3.4-s epochs starting 100 ms before the precue and ending 1.5 s after the response signal. After removing all segments with excessive activity in the foreperiod, trials were classified as hits, false alarms, or omissions based on the EMG. [...] In a first step, we calculated the maximal corrugator and zygomaticus amplitude value in the average for valid trials for each participant (i.e., anger valid for corrugator and happiness valid for zygomaticus). The EMG onset for each trial was determined as the point in time where the amplitude in a given muscle reached 25% of the individual maximal value of that muscle in the average. All trials with EMG activity exceeding the 25% threshold during the last 500 ms of the foreperiod were considered failures to inhibit the response and excluded from analyses (1.25% of the data). After that, the baseline was established 100 ms before the response signal, focusing on the 1.5-s period after the onset of the response signal. Hits, omissions, and false positives were calculated based on muscular activities during the response period as follows. We scored as hits all trials with activity above 25% of the maximum in the target muscle (i.e., corrugator for anger and zygomaticus for happiness), and as omissions the trials with activity below the threshold in both muscles. We considered as false positives those trials with EMG activity below 25% of the maximum in the target muscle and, at the same time, activity above 25% in the nontarget muscle. This criterion does not yield false positives if a subject activates both muscles to produce one of the expressions.

- Fridlund and Cacioppo: http://onlinelibrary.wiley.com/doi/10.1111/j.1469-8986.1986.tb00676.x/epdf

> on filtering, smoothing (cf. Korb), measurement units / averaging, denoising, types of baseline, analysis in frequency & time domain and more

- Korb: http://www.sciencedirect.com/science/article/pii/S0301051110002115

> Using Matlab (The Mathworks, Natick, MA), data was filtered (30–400 Hz), down-sampled to 256 Hz, full-wave rectified, segmented (−250 ms pre-stimulus to +1500 ms poststimulus onset), baseline corrected using the pre-stimulus period, and smoothed with a sliding average window of 3 time frames (TFs, 12 ms). Trials with baseline amplitudes over 30 mV were excluded from analyses. Percentages of excluded trials per condition ranged from 4.42 to 6.26 (Chi-square = .54, p > .9). EMG-onsets were defined as the earliest TF at which amplitude of the left zygomaticus muscle exceeds the mean plus two SDs of the baseline, and stays above this threshold for at least 20 TFs (78 ms). Go trials presenting an EMG-onset were defined as correct Go responses (average and SD of number of trials for Go-Neutral: 176.25 (29.47) and GoHappy: 172.96 (29.93)). Go trials without EMG-onset were defined as misses. NoGo trials containing an EMG-onset were defined as false alarms. Data was averaged over bins of 125 ms. Correct Go trials, correct NoGo trials in which no EMG-onset was found and in which zygomatic activation did not exceed 30 mV,1 and misses during Go trials, were analyzed in separate two Stimulus (Neutral, Happy) × two Muscle (Corrugator, Zygomaticus) repeated measures MANOVAs (O’Brien and Kaiser, 1985).

## Todo
- [ ] overview of methods for artefact detection (cf. reference papers)
- [ ] hit / miss / no-response definition

