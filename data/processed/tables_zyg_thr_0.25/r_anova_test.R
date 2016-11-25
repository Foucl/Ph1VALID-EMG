require(dplyr)
require(tidyr)
require(ez)
require(knitr)
require(ggplot2)

ds <- read.csv("subjinfo_behav.csv")

# wide -> long

ds_rp <- ds %>% select(subjid, ends_with("Rp"))
ds_rp_rt <- ds_rp %>% select(subjid, contains("meanRT"))

ds_ts_rt <- ds %>% select(subjid, contains("meanRT"))

ds_wide <- ds_ts_rt %>% gather(var, meanRT, contains("meanRT"))
ds_wide <- ds_wide %>% separate(var, c('em', 'cond', 'measure', 'exp'), sep="_") %>% select(-measure)
ds_wide <- ds_wide %>% filter(!is.nan(meanRT))



fit.ez <- ezANOVA(data=as.data.frame(ds_wide), wid=subjid, dv=as.numeric(meanRT), within=.(em, cond), detailed=T)
kable(fit.ez[[1]], digits=3)

summaryStat <- ds_wide %>%
  group_by(subjid, exp, em, cond) %>%
  summarise(meanRT = mean(meanRT), n = n(), sd = sd(meanRT)) %>%
  group_by(exp, em, cond) %>%
  summarise(mean = mean(meanRT), n=n(), sd= sd(meanRT), sem = sd(meanRT) / sqrt(n())) %>%
  mutate(ymin = mean - sem, ymax= mean+ sem)

pd <- position_dodge(.1) 
ggplot(summaryStat, aes(x=cond, y=mean, colour=em, group=em, ymin=ymin, ymax=ymax)) + 
  geom_errorbar(width=.1, position=pd)  +
  geom_line(position=pd, aes(group=em)) +
  geom_point(position=pd)

