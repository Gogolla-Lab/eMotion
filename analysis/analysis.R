library(tidyverse)
library(rstatix)
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
  theme_light() + ylab('Nr. of zone transitions') + theme(text = element_text(size=20)) +
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

# Nr. of transitions facet by opto/x=group
test <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  group_by(opto) %>% wilcox_test(transitions ~ group)
test

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white'),
           facet.by = 'opto') +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 120) +
  #stat_pvalue_manual(test, label = 'p.adj', y.position = c(87.5,95,102.5)) +
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

# Nr. of transitions per period (requires adjusted-p)
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

# Nr. of transitions per period (facet by period, x=group)
transitions_test <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  group_by(period) %>% wilcox_test(transitions ~ group)
transitions_test

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggviolin(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group',
           add='boxplot', add.params = list(color = 'group', fill='white'),
           facet.by = 'period') +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 65, label.x.npc = 'left') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions over days

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='day', y='transitions', color = 'group', fill = 'group', size = 1,
         add = c("mean_se", "dotplot"), add.params = list(alpha=0.5)) +
  theme_light() + ylab('Nr. of zone transitions') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 140, size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Nr. of transitions over days per period
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='day', y='transitions', color = 'group', fill = 'group', size=1,
         add = c("mean_se", "dotplot"), add.params = list(alpha=0.5), facet.by = 'period') +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position = 'top') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 50, size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone based on unfiltered counting (included)
test <- df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(zone) %>%
  wilcox_test(cum_time_sec ~ group)
test

df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggviolin(x='group', y='cum_time_sec', color = 'group', fill = 'group', alpha=0.5,
           facet.by = 'zone',
           add = 'boxplot', add.params = list(color = 'group', fill='white')) +
  ylab('Cumulative ROI time (min)') +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(label.y = 70, size=6) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(50,62,56), size = 6) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone based on unfiltered counting - faceted by period (included)
test <- df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, period, zone) %>% count(zone) %>%
  group_by(group, animal, day, period, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(period, zone) %>%
  wilcox_test(cum_time_sec ~ group)
test

df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, period, zone) %>% count(zone) %>%
  group_by(group, animal, day, period, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggviolin(x='group', y='cum_time_sec', color = 'group', fill = 'group', alpha=0.5,
           facet.by = c('zone', 'period'),
           add = 'boxplot', add.params = list(color = 'group', fill='white')) +
  ylab('Cumulative ROI time (min)') + ylim(-7,30) +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(size=4, label.y = 28) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(14,22,18), size = 4) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone over days ###################################
df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggline(x='day', y='cum_time_sec', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), add.params = list(alpha=0.5),
         facet.by = c('zone')) +
  ylab('Cumulative ROI time (min)') + ylim(0,51) +
  theme_light() + theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', size=8, label.y = 42) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# Time spent in zone based on unfiltered counting (to compare with anymaze)
df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>%
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=sum(n)/30) %>%
  dplyr::filter(group == 'chr') %>%
  ggboxplot(x='zone', y='cum_time_sec') +
  ylab('Cumulative ROI time (s)') +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))

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

# Bout durations per zone/per period || get the q4 nest
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

# Bout durations over days (shows increase) ***
test <- df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  group_by(zone) %>% kruskal_test(mbd ~ group)
test

df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggline(x='day', y='mbd', color = 'group', fill = 'group',
         add = c('mean_se'), add.params = list(alpha=0.25), facet.by = c('bout_zone')) +
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
test <- df %>% select(!c('bout_duration', 'bout_zone')) %>% na.omit() %>%
  dplyr::group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  mutate(a = 'a') %>% group_by(a) %>%
  wilcox_test(locomotion~group)
test


df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggviolin(x='group', y='locomotion', alpha=0.5, color = 'group', fill = 'group',
           add = 'boxplot', add.params = list(color = 'group', fill='white')) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 420, label.x.npc = 'left', size=8) +
  stat_pvalue_manual(test, label ='p.adj.signif', y.position = c(300, 350, 325), size=8) +
  #stat_compare_means(comparisons = group_comparisons,
  #                   aes(method = 'wilcox.test', label = ..p.signif..))  +
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
  ggline(x='day', y='locomotion', color='group', fill='group', size = 1,
           add = c('mean_se', 'dotplot'), add.params = list(alpha=0.5)) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), size=8, label = 'p.signif') +
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
  facet_grid(~period) + ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 200) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

###### SPEED #####

#speed - faceted by period
test <- df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(group) %>% wilcox_test(bout_velocity ~ period)
test

df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  ggviolin(x='period', y='bout_velocity', color = 'group', fill = 'group', alpha=0.5,
           add = 'boxplot', facet.by = 'group',
           add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Average speed (cm/s)') + theme(text = element_text(size=20)) +
  stat_compare_means(label.x.npc = 'left') +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(3, 4, 5, 6, 7, 8), size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#speed - faceted by zone
test <- df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(bout_zone) %>% wilcox_test(bout_velocity ~ group)
test

df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  ggviolin(x='group', y='bout_velocity', color = 'group', fill = 'group', alpha=0.5,
           add = 'boxplot', facet.by = 'bout_zone',
           add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Average speed (cm/s)') + theme(text = element_text(size=20)) +
  stat_compare_means(label.x.npc = 'left') +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(4, 6, 5), size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))


### Speed overall
test <- df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(group, animal, day) %>%
  summarise(avg_speed = mean(bout_velocity)) %>% mutate(a='a') %>%
  group_by(a) %>% wilcox_test(avg_speed ~ group)
test

df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(group, animal, day) %>%
  summarise(avg_speed = mean(bout_velocity)) %>%
  ggviolin(x='group', y='avg_speed', color = 'group', fill = 'group', alpha=0.5,
           add = 'boxplot', add.params = list(color = 'group', fill='white')) +
  theme_light() + ylab('Average speed (cm/s)') + theme(text = element_text(size=20)) +
  stat_compare_means(label.x.npc = 'left', size=4, label.y = 0.8) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(0.5, 0.7, 0.6), size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

### Speed per bout averaged
test <- df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(group, animal, day, bout_zone) %>%
  summarise(avg_speed = mean(bout_velocity)) %>%
  group_by(bout_zone) %>% wilcox_test(avg_speed ~ group)
test

df %>% select(!c(cum_dist_cm, bout_duration)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'eating') %>%
  group_by(group, animal, day, bout_zone) %>%
  summarise(avg_speed = mean(bout_velocity)) %>%
  ggviolin(x='group', y='avg_speed', color = 'group', fill = 'group', alpha=0.5,
           add = 'boxplot', add.params = list(color = 'group', fill='white'),
           facet.by = 'bout_zone') +
  theme_light() + ylab('Average speed (cm/s)') + theme(text = element_text(size=20)) +
  stat_compare_means(label.x.npc = 'left', size=4, label.y = 0.8) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(0.5, 0.7, 0.6), size=8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

dev.off()