library(tidyverse)
library(ggpubr)

df <- read_csv("~/Desktop/combined.csv")
df <- df %>% dplyr::rename('frame' = 'X1')
df$group <- as.factor(df$group)
df$day <- as.factor(df$day)

# Group comparisons
group_comparisons <- list( c("chr", "ctrl"), c("ctrl", "hr"), c("chr", "hr") )
# Period comparisons
period_comparisons <- list( c("q1", "q2"), c("q2", "q3"), c("q3", "q4"),
                            c("q1", "q3"), c("q2", "q4"), c("q1", "q4") )
# Opto comparisons
opto_comparisons <- list( c("True", "False") )
# Day comparisons
day_comparisons <- list( c("1", "2"), c("2", "3"), c("3", "4"), c("4", "5"))

# Nr. of transitions
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 180, label.x.npc = 'left') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions per opto
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='opto', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(~group) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(comparisons = opto_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions over days/per opto
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='opto', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(day~group) +
  theme_light() + ylab('Nr. of zone transitions') +
  #stat_compare_means(label.y = 110, label.x.npc = 'left') +
  stat_compare_means(comparisons = opto_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions per period
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='period', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(~group) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 90, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions over days
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='day', y='transitions', color = 'group', fill = 'group',
         add = c("mean_se", "dotplot"), add.params = list(alpha=0.5)) +
  facet_grid(~group) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 160, label.x.npc = 'left') +
  #stat_compare_means(comparisons = day_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone based on unfiltered counting (to compare with anymaze)
df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>%
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggboxplot(x='zone', y='cum_time_sec', fill = 'group') + facet_grid(~group) +
  ylab('Cumulative -unfiltered- bout time (s)') +
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone based on filtered bout data
df %>% select(!c(cum_dist_cm, bout_velocity)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>%
  summarize(total_sec = sum(bout_duration)) %>%
  ggboxplot(x='bout_zone', y='total_sec', fill = 'group') + facet_grid(~group) +
  ylab('Cumulative bout time (s)') + 
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#pdf(file = 'plots.pdf' ,paper = "a4")
# Bout durations per zone
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =3.9, label.x.npc = 'left') +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations per zone/per opto
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(opto~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations per zone/per opto 2nd
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='opto', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(group~bout_zone) + scale_y_log10() +
  #stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  stat_compare_means(comparisons = opto_comparisons, aes(method = 't.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations per zone/per period
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggviolin(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(period~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations over days (shows increase)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggline(x='day', y='mbd', color = 'group', fill = 'group',
         add = c('mean_se'), add.params = list(alpha=0.25), facet.by = 'group') +
  theme_light() + ylab('Mean bout duration (s)') +
  #stat_compare_means(label.x.npc = 'left') +
  #stat_compare_means(comparisons = day_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Bout durations over days (group comparisons)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggviolin(x='group', y='mbd', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white'),
           facet.by = c('bout_zone', 'day')) +
  theme_light() + ylab('Mean bout duration (s)') + scale_y_log10() +
  stat_compare_means(label.y=4.7, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggviolin(x='group', y='locomotion', alpha=0.5, color = 'group', fill = 'group',
           add = 'boxplot', add.params = list(color = 'group', fill='white')) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 500, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# ignore
# Total locomotion per animal
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggboxplot(x='animal', y='locomotion', color='group',
                                add = 'jitter') +
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
    color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
    fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# ignore
# Total locomotion over days
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggline(x='day', y='locomotion', color='group',
            add = c('mean_se', 'jitter'), facet.by = 'group') + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 350) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion over days per group
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggviolin(x='day', y='locomotion', color='group', alpha=0.5, fill='group',
           add = 'boxplot', add.params = list(color = 'group', fill='white')) + 
  facet_grid(~group) +
  theme_light() + ylab('cumulative locomotion (m)') +
  stat_compare_means(label.y = 500) + 
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion over days per animal
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggline(x='day', y='locomotion', color='group', alpha=0.5, fill='group') + 
  facet_grid(~animal) +
  theme_light() + ylab('cumulative locomotion (m)') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Total locomotion per period
df %>% group_by(group, animal, day, period) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggviolin(x='group', y='locomotion', color='group', fill='group', alpha=0.5,
           add = 'boxplot', add.params = list(color = 'group', fill='white')) + 
  theme_light() +
  facet_grid(~period) + ylab('cumulative locomotion (m)') +
  stat_compare_means(label.y = 200) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Overall time
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, period, bout_zone) %>% summarise(t = sum(bout_duration)/60) %>%
  ggviolin(x='group', y='t', color='group', fill='group', alpha = 0.5,
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  facet_grid(period~bout_zone) + theme_light() +
  stat_compare_means(label.y = 15) +
  stat_compare_means(comparisons = group_comparisons, method = 'wilcox.test') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Overall time over days
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone, period) %>% summarise(t = sum(bout_duration)/60) %>%
  ggviolin(x='day', y='t', fill='group', color = 'group', alpha = 0.5,
           add='boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() +
  facet_grid(group~bout_zone) +
  stat_compare_means(label.y = 75) +
  stat_compare_means(comparisons = day_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

dev.off()
# Transitions
animal_split <- df %>% select(c(group, animal, day, period, bout_zone)) %>% 
  dplyr::group_split(animal, day, period)

animal_split