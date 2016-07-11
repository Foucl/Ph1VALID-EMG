# DV Reaction Time

## Marginal Distributions
(with smoothed probability density kernel)

![](../../reports/figures/rtDistributions.png)

## Marginal Means

|exp |em |cond  |   mean|  n|     sd|    sem|   ymin|   ymax|
|:---|:--|:-----|------:|--:|------:|------:|------:|------:|
|Pr  |AN |inval | 0.8085| 42| 0.1659| 0.0256| 0.7829| 0.8341|
|Pr  |AN |val   | 0.6828| 42| 0.1381| 0.0213| 0.6615| 0.7041|
|Pr  |HA |inval | 0.6914| 42| 0.1790| 0.0276| 0.6637| 0.7190|
|Pr  |HA |val   | 0.5163| 42| 0.1723| 0.0266| 0.4897| 0.5429|
|Sw  |AN |inval | 0.5514| 42| 0.1033| 0.0159| 0.5354| 0.5673|
|Sw  |AN |val   | 0.5796| 42| 0.1135| 0.0175| 0.5621| 0.5971|
|Sw  |HA |inval | 0.4370| 42| 0.1051| 0.0162| 0.4208| 0.4533|
|Sw  |HA |val   | 0.4251| 42| 0.1036| 0.0160| 0.4091| 0.4410|

## Testing effects on reaction time
rmANOVA with rt = intercept + emotion + validity + emotion*validity  
error Bars = standard error of the mean

### Response Priming
|Effect      | DFn| DFd|     SSn|   SSd|       F|      p|p<.05 |    $\eta^2$|
|:-----------|---:|---:|-------:|-----:|-------:|------:|:-----|------:|
|(Intercept) |   1|  41| 76.4856| 3.130| 1002.04| 0.0000|*     | 0.9451|
|em          |   1|  41|  0.8449| 0.966|   35.87| 0.0000|*     | 0.1598|
|cond        |   1|  41|  0.9495| 0.233|  167.10| 0.0000|*     | 0.1761|
|em:cond     |   1|  41|  0.0256| 0.114|    9.21| 0.0042|*     | 0.0057|

![](../../reports/figures/Rp_interaction_rt.png)

### Response Switching
|Effect      | DFn| DFd|        SSn|       SSd|           F|         p|p<.05 |       $\eta^2$|
|:-----------|---:|---:|----------:|---------:|-----------:|---------:|:-----|---------:|
|(Intercept) |   1|  41| 41.7095638| 1.3723817| 1246.076175| 0.0000|*     | 0.9573|
|em          |   1|  41|  0.7591773| 0.2926622|  106.355605| 0.0000|*     | 0.2900|
|cond        |   1|  41|  0.0027717| 0.0993028|    1.144368| 0.2910|      | 0.0015|
|em:cond     |   1|  41|  0.0169572| 0.0943336|    7.370055| 0.0097|*     | 0.0090|

![](../../reports/figures/Ts_interaction_rt.png)
