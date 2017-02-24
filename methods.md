Focus on differences to Should I Smile of Should I Frown (SISoSIF).

## Data Acquisition / Electrophysiological Recordings
- BioSemi Reference Free (CMS/DRL)
- Bipolar EMG electrodes, left Cor & Zyg [Ag/Ag-Cl, Friedlund & Cacioppo ...] -> Korb's go-nogo paper might be a decent (if brief) template for describing a facial EMG biosemi setup
- DRL: Placed centrally on forehead
- CMS: between Zyg and Cor electrodes (usually roughly 3 cm below left eye)
- recorded at 1024 Hz
- downsampled offline to 128 Hz

## Data Analysis (EMG)
- Software: Matlab & Fieldtrip (recommended wording from fieldtrip website: "The data analysis was performed using the Fieldtrip toolbox for EEG/MEG-analysis (Oostenveld, Fries, Maris, & Schoffelen, 2010; Donders Institute for Brain, Cognition and Behaviour, Radboud University Nijmegen, the Netherlands. See http://www.ru.nl/neuroimaging/fieldtrip")). Matlab should qualify as 'standard software' in the eye of APA and doesn't need to be cited.

### Preprocessing
- Offline Filtering: 10 Hz Lowpass Butterfly Filter of order 2
- Montage & rectification identical to SISoSIF
- Segmentation into 4.5s epochs, (beginning 200ms before onset S1, ending 500ms after offset S2)
- baseline removal: 200ms before S1

#### z standardization
- Prior to classification, each data point in each epoch was z standardized relative to the whole experiment: The mean and standard deviation used in this normalization were calculated accross all trials (regardless of condition).
  - for discussions of standardizing facial EMG data see e.g.: https://www.ncbi.nlm.nih.gov/pmc/articles/PMC2825576/ who also cite https://www.ncbi.nlm.nih.gov/pubmed/17999934
  - *(I am realizing now that the way I standardized this is not very clean: The segment length (4.5s) is shorter than the actual trial duration (6.8s); thus, the first 300 and last 2000 ms of each trial are not used for calculating the mean and SD for each channel)*

### Classification
- Identical to SISoSIF, only difference: Threshold: 25% Cor, 50% Zyg
- Splitting into 4 conditions, removal of Inhibition Errors, re-baselining to S2, Hit/Miss/FP Classification identical to SISoSIF
- RT: Outliers on trial level: >= mean +/- 2 SD (for each of the four conditions)
- Errors: Outliers on subject level: no idea whom you excluded and based on what criteria

## Lit
Oostenveld, R., Fries, P., Maris, E., & Schoffelen, J.-M. (2010). FieldTrip: Open Source Software for Advanced Analysis of MEG, EEG, and Invasive Electrophysiological Data. Computational Intelligence and Neuroscience, 2011, e156869. https://doi.org/10.1155/2011/156869

http://onlinelibrary.wiley.com/doi/10.1111/psyp.12220/full
> **Electrophysiological Recordings**
> The EMG was recorded from zygomaticus and corrugator muscles with Ag/AgCl electrodes according to the guidelines described in Fridlund and Cacioppo (1986). For each muscle, two electrodes filled with a conductive gel were attached to the left side of the face with adhesive pads; ground was placed on the upper half of the right forehead. Impedances were kept below 10 kΩ. The EMG signal was measured, rectified, and integrated (time constant = 10 ms) using a Coulbourn V76–23a Hi amplifier. Low- and high-pass filters were set at 10 kHz and 8 Hz, respectively. The raw signal was digitized with the BrainVision recording software (Brain Products GmbH, Munich, Germany) and sampled at a frequency of 1 kHz.
> EEG was recorded from 40 Ag/AgCl electrodes using a BrainAmp DC amplifier (Brain Products GmbH), filtered online with a band-pass of 0.032–125 Hz, and a notch filter at 50 Hz, and sampled at 1000 Hz. Electrode impedances were kept below 5 kΩ. All electrodes were referenced to the left mastoid. Electrooculogram was measured on both sides at the external canthi and below the right eye.

> **Data Analyses**
> The preprocessing and analyses of the EMG and EEG signals included three steps. First, both signals were segmented together in 3.4-s epochs starting 100 ms before the precue and ending 1.5 s after the response signal. After removing all segments with excessive activity in the foreperiod, trials were classified as hits, false alarms, or omissions based on the EMG. Second, EEG signal was separated from EMG, and ERPs were averaged in shorter epochs. Third, EMG and ERP data were analyzed separately for all conditions. For ERPs, we analyzed the foreperiod and response signal epochs. EMG analyses focused on the response signal period only.

> **EMG and EEG signal preprocessing**
> The initial common preprocessing was based on the EMG onset for each muscle. In a first step, we calculated the maximal corrugator and zygomaticus amplitude value in the average for valid trials for each participant (i.e., anger valid for corrugator and happiness valid for zygomaticus). The EMG onset for each trial was determined as the point in time where the amplitude in a given muscle reached 25% of the individual maximal value of that muscle in the average. All trials with EMG activity exceeding the 25% threshold during the last 500 ms of the foreperiod were considered failures to inhibit the response and excluded from analyses (1.25% of the data). After that, the baseline was established 100 ms before the response signal, focusing on the 1.5-s period after the onset of the response signal. Hits, omissions, and false positives were calculated based on muscular activities during the response period as follows. We scored as hits all trials with activity above 25% of the maximum in the target muscle (i.e., corrugator for anger and zygomaticus for happiness), and as omissions the trials with activity below the threshold in both muscles. We considered as false positives those trials with EMG activity below 25% of the maximum in the target muscle and, at the same time, activity above 25% in the nontarget muscle. This criterion does not yield false positives if a subject activates both muscles to produce one of the expressions.

> **ERP preprocessing**
> After selecting only hits trials not exceeding the 25% threshold of EMG activity in the foreperiod—thus precluding EMG artifacts in the CNV—the EEG signal was separated from EMG and segmented into shorter epochs to minimize the number of trials rejected due to artifacts. Blinks and artifacts from facial movements were removed with independent components analyses. Offline, all channels were low-pass filtered at 30 Hz (12 dB/oct), and recalculated to average mastoid reference. Segments with amplitudes exceeding ± 200 μV were considered artifacts and removed (5.2% of the data). For the ERPs during the foreperiod (CNV), all channels were segmented into 2.8-s epochs starting 100 ms before precue onset (baseline) and ending 900 ms after the response signal. ERP components following the response signal were segmented into shorter epochs, from 100 ms before until 900 ms after the response signal, again aiming to minimize impact of artifact rejection. For these segments, the baseline correction was established 100 ms before the response signal. All averaged ERPs submitted to analyses had at least 10 epochs in each experimental condition. The mean number of trials per condition were happiness valid M = 75.17, SE = .81; anger valid M = 71.08, SE = 1.27; happiness invalid M = 17.90, SE = .23; and anger invalid M =18.51, SE = .31.

> **Performance: EMG analyses**
> Data from EMG peak amplitudes and RTs for correct responses, hits, and errors were submitted to repeated measures analyses of variance (rmANOVA) with factors expression (happiness, anger) and validity (valid, invalid precue). It should be noted that the factor expression reflects not only differences between expressions, but also contraction of different muscles (zygomaticus and corrugator). Therefore, significant differences in factor expression—especially regarding RTs—should be taken with care. Post hoc t tests for RTs compared the validity effect (difference in RT between valid and invalid) in happiness and anger. All post hoc tests were Bonferroni corrected for multiple testing. We also correlated measures of RTs with hits and errors by means of Pearson correlations.
