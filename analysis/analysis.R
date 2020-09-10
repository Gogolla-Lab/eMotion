library(tidyverse)
library(ggpubr)

df <- read_csv(r"{J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs\cleaned\combined.csv}")
df <- df %>% dplyr::rename('frame' = 'X1')
df$group <- as.factor(df$group)
df$day <- as.factor(df$day)

# Group comparisons
group_comparisons <- list( c("chr", "ctrl"), c("ctrl", "hr"), c("chr", "hr") )
# Period comparisons
period_comparisons <- list( c("q1", "q2"), c("q3", "q4"), c("q1", "q3"),
                            c("q2", "q4"), c("q1", "q4"), c("q2", "q3") )
# Opto comparisons
opto_comparisons <- list( c("TRUE", "FALSE") )
# Day comparisons
day_comparisons <- list( c("1", "2"), c("2", "3"), c("3", "4"), c("4", "5"))

#df %>% select(!c(cum_dist_cm, bout_velocity)) %>% group_by(group, animal, day)



# Bout durations per zone
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + 
  facet_grid(~bout_zone) + scale_y_log10() + stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations per zone/per period
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(period~bout_zone) + scale_y_log10() + stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  theme_light() + 
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations over days
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='day', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(bout_zone~group) + scale_y_log10() + stat_compare_means(label.y=4.7, label.x.npc = 'left') +
  theme_light() + 
  stat_compare_means(comparisons = day_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = max(cum_dist_cm, na.rm=TRUE)) %>%
  ggviolin(x='group', y='locomotion', color='group', add = 'jitter', shape='day') + 
  stat_compare_means(label.y = 50000) + stat_compare_means(comparisons = group_comparisons,
                                                           aes(method = 'wilcox.test',
                                                               label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion over days
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = max(cum_dist_cm, na.rm=TRUE)) %>%
  ggviolin(x='day', y='locomotion', color='group', group='group', add = 'jitter') + 
  facet_grid(~group) +
  stat_compare_means(label.y = 45000) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion per period
df %>% group_by(group, animal, day, period) %>%
  summarise(locomotion = max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE)) %>%
  ggviolin(x='group', y='locomotion', color='group', add = 'jitter', shape='day') + 
  facet_grid(~period) +
  stat_compare_means(label.y = 20000) + stat_compare_means(comparisons = group_comparisons,
                                                           aes(method = 'wilcox.test',
                                                               label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))


# Overall time
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(t = sum(bout_duration)) %>%
  ggviolin(x='group', y='t', fill='group', add='boxplot') + facet_grid(period~bout_zone) + 
  stat_compare_means(label.y = 12000) +
  stat_compare_means(comparisons = group_comparisons, method = 'wilcox.test') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Overall time over days
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone, period) %>% summarise(t = sum(bout_duration)) %>%
  ggviolin(x='day', y='t', fill='group', add='boxplot') + facet_grid(group~bout_zone) +
  stat_compare_means(label.y = 3500) +
  stat_compare_means(comparisons = day_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Transitions
animal_split <- df %>% select(c(group, animal, day, period, bout_zone)) %>% 
  dplyr::group_split(animal, day, period)

animal_split