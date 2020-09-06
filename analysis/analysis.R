library(tidyverse)

df <- read_csv(r"{J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs\cleaned\combined.csv}")
df <- df %>% dplyr::rename('frame' = 'X1')

# Group comparisons
group_comparisons <- list( c("chr", "ctrl"), c("chr", "hr"), c("ctrl", "hr") )
# Period comparisons
period_comparisons <- list( c("q1", "q2"), c("q3", "q4"), c("q1", "q3"),
                            c("q2", "q4"), c("q1", "q4"), c("q2", "q3") )
# Opto comparisons
opto_comparisons <- list( c("TRUE", "FALSE") )

df %>% select(!c(frame, time, animal, day, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% group_by(group, zone) %>% 
  ggplot(aes(x=bout_zone, y=bout_duration, fill=group)) +
  geom_boxplot() + facet_grid(.~period) + theme_gray() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

df %>% select(!c(frame, time, animal, day, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% group_by(group, zone) %>% 
  ggplot(aes(x=bout_zone, y=bout_duration, fill=group)) +
  geom_boxplot() + facet_grid(.~opto) + theme_gray() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))