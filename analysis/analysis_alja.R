library(tidyverse)
library(rstatix)
library(ggpubr)
library(ruler)


patha = "C:/Users/apodgornik/Desktop/temp/combined_2.csv"
df <- read_csv(patha)
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

# NR. OF TRANSITIONS ----

#1 No of transitions faceted by day
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, facet.by = 'day') +
  theme_light() + ylab('Nr. of zone transitions') + theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 180, label.x.npc = 'left', size = 5) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)


#2 Nr. of transitions - averaged over days
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>% 
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  theme_light() + ylab('Nr. of zone transitions') + theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 600, label.x.npc = 'left', size = 5) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) 

#3 Nr. of transitions per opto
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggboxplot(x='opto', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  facet_grid(~group) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(comparisons = opto_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#4 Nr. of transitions facet by opto/x=group
test_opto <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  group_by(opto) %>% wilcox_test(transitions ~ group)
test_opto

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  mutate(mean_transitions = mean(transitions)) %>% #filter(group != 'hr') %>%
  #filter(transitions < 266) %>% #outliers above
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
            facet.by = 'opto') +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 320) +
  #stat_pvalue_manual(test_opto, label = 'p.adj', y.position = c(87.5,95,102.5)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))+
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#5 Nr of transitions per opto per zone
test_opto_zone <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% 
  group_by(group, animal, day, opto, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  group_by(opto, zone) %>% wilcox_test(transitions ~ group)
test_opto_zone

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  #filter(group != 'hr') %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>%
  group_by(group, animal, opto, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  mutate(mean_transitions = mean(transitions)) %>% 
  #filter(transitions < 266) %>% #outliers above
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
            #facet.by = c('opto', 'zone)
            ) +
  facet_grid(opto~zone) +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 120) +
  #stat_pvalue_manual(test_opto_zone, label = 'p.adj', y.position = c(87.5,95,102.5)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))+
  geom_point(position = position_jitter(.2), size = 2, shape = 21)
   
#6 same as above but individual animals coloured
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  mutate(mean_transitions = mean(transitions)) %>% filter(group != 'hr') %>%
  #filter(transitions < 266) %>% #outliers above
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'black', outlier.shape = NA,
            facet.by = 'opto') +
  theme_light() + ylab('Nr. of zone transitions') +
  stat_compare_means(label.y = 320) +
  #stat_pvalue_manual(test, label = 'p.adj', y.position = c(87.5,95,102.5)) +
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 3, shape = 16) 

#7 Nr. of transitions over days/per opto
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% 
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggboxplot(x='opto', y='transitions', alpha = 0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  facet_grid(day~group) +
  theme_light() + ylab('Nr. of zone transitions') + ylim(0,100) +
  stat_compare_means(label.y = 90, label.x.npc = 'left') +
  stat_compare_means(comparisons = opto_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#8 Nr. of transitions over days/per opto - each animal coloured
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% 
  group_by(group, animal, day, opto) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggboxplot(x='opto', y='transitions', alpha = 0.5, color = 'black', outlier.shape = NA) +
  #scale_fill_brewer(palette = 'RdYIBu') +
  facet_grid(day~group) +
  theme_light() + ylab('Nr. of zone transitions') + ylim(0,100) +
  stat_compare_means(label.y = 90, label.x.npc = 'left') +
  stat_compare_means(comparisons = opto_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 3, shape = 16) 
  
#9 Nr. of transitions per period (requires adjusted-p) - line plot
test_trans_period <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(group != 'hr') %>%
  group_by(group, animal, day, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  group_by(group, day, zone) %>% kruskal_test(transitions ~ period)
test_trans_period

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% #filter(group != 'hr') %>%
  group_by(group, animal, day, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  ggline(x='period', y='transitions', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), facet.by = c('zone', 'day')) +
  facet_grid(c('zone', 'day'), scales = 'free_y') +
  theme_light() + ylab('Nr. of zone transitions') + #ylim(0, 55) +
  stat_compare_means(aes(group=group), label.y = c(17, 20, 23, 26), label.x.npc = 'left', label = 'p') +
  #stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) 
  #geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 3, shape = 16)

#9.1 Nr. of transitions/min per period (requires adjusted-p) - line plot + filtered outliers
test_trans_out <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, zone, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  group_by(period, zone) %>% wilcox_test(transitions ~ group)
test_trans_out

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% #do the stats for this one
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% 
  #filter(animal != 'ctrl1') %>% filter(animal != 'ctrl2') %>% filter(animal != 'ctrl9') %>% 
  #filter(animal != 'chr1') %>% 
  #filter(animal != 'chr6') %>% 
  filter(group != 'hr') %>%
  group_by(group, animal, day, zone, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='period', y='transitions', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), facet.by = c('zone', 'day')) +
  facet_grid(c('zone', 'day'), scales = 'free_y') +
  theme_light() + ylab('Nr. of zone transitions') + #ylim(0, 55) +
  #stat_compare_means(label.y = 20, label.x.npc = 'left') +
  #stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) 

#9.2 Nr. of transitions per period (requires adjusted-p) - boxplot, not faceted

#across groups
test_group <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  group_by(zone, group) %>% wilcox_test(transitions ~ period)
test_group %>%
  filter(p < 0.05)

#across periods
test_period_kw <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  group_by(zone, period) %>% kruskal_test(transitions ~ group)
test_period_kw %>%
  filter(p < 0.05)

#across periods - wilcox
test_period_wcx <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  group_by(zone, period) %>% kruskal_test(transitions ~ group)
test_period_wcx %>%
  filter(p.adj < 0.05)


df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>%
  #filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>%
  ggboxplot(x='period', y='mean_transitions', color = 'group', fill = 'group', facet.by = 'zone', add = 'jitter', alpha = 0.5) +
  #facet_grid(c('zone'), scales = 'free_y') +
  theme_light() + ylab('Nr. of zone transitions') + #ylim(0, 55) +
  #stat_compare_means(aes(group=group), label.y = c(17, 20, 23, 26), label.x.npc = 'left', label = 'p') +
  #stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) 

#10 Nr. of transitions per period (requires adjusted-p) - line plot for individual groups

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(group == 'ctrl') %>%
  group_by(group, animal, day, period, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='period', y='transitions', color = 'black', size = 1,
         add = c("mean_se"), facet.by = c('zone', 'day')) +
  scale_fill_brewer(palette = 'Paired') +
  facet_grid(c('zone', 'day'), scales = 'free_y') +
  theme_light() + ylab('Nr. of zone transitions') + #ylim(0, 55) +
  #stat_compare_means(label.y = 100, label.x.npc = 'left') +
  #stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) 
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 3, shape = 16) 


#11 Nr. of transitions per period (requires adjusted-p)
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggboxplot(x='period', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, facet.by = c('group','day')) +
  theme_light() + ylab('Nr. of zone transitions') + ylim(0, 90) +
  stat_compare_means(label.y = 90, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#12 Nr. of transitions per period (facet by period, x=group) 
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>% 
  filter(transitions < 133) %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
            facet.by = 'period') + 
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 160, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#13 Nr. of transitions per period (facet by period, x=group) - averaged zones per animal
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, zone, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>% 
  #filter(transitions < 34) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>%
  #filter(group != 'hr') %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, 
            facet.by =  c('period', 'zone')) + ylim(0, 80) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 70, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#14 Nr. of transitions per period (facet by period,day, x=group) - averaged zones per animal
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% 
  group_by(group, animal, period, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>% 
  #filter(transitions < 34) %>%
  #filter(group != 'hr') %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, 
            facet.by =  c('period', 'day')) + ylim(0, 80) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 70, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)


#15 Nr. of transitions per period (facet by period,day, x=group) - averaged zones per animal
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%  
  group_by(group, animal, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% group_by(group, animal, zone) %>%
  mutate(mean_transitions = mean(transitions)) %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, 
            facet.by =  c('zone')) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 210, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c(
    "#5f8cde",
    "#b0b0b0", 
    "#dea15f"
    )) +
  fill_palette(c(
    "#5f8cde", 
    "#b0b0b0", 
    "#dea15f"
    )) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#15.1 Nr. of transitions per period (facet by period,day, x=group) - averaged zones per animal
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>% filter(group != 'hr') %>% filter(period == 'q4') %>% 
  group_by(group, animal, zone) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% group_by(group, animal, zone) %>%
  mutate(mean_transitions = mean(transitions)) %>%
  #filter(transitions < 34) %>%
  filter(group != 'hr') %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, 
            facet.by =  c('zone')) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 70, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
                 )) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#16 Nr. of transitions per period (facet by period, x=group) - averaged zones per animal
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, zone, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  mutate(mean_transitions = mean(transitions)) %>% 
  #filter(transitions < 34) %>%
  filter(group != 'hr') %>% filter(period == 'q1') %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% 
  #filter(zone != 'social') %>%
  #filter(zone != 'interzone') %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'black', outlier.shape = NA) + 
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  stat_compare_means(label.y = 30, label.x.npc = 'left') +
  stat_compare_means(comparisons = period_comparisons, method = 'wilcox.test', label = 'p.signif') +
  #stat_pvalue_manual(transitions_test, label = "p.adj.signif", y.position = c(55,60,65)) +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  geom_point(aes(colour = factor(zone), shape = factor(zone)), position = position_jitter(.2), size = 3, shape = 16)

#17 Nr. of transitions per period (facet by day, x=group) - averaged zones per animal - stats don't work
test_period <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, zone, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  #mutate(mean_transitions = mean(transitions)) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% group_by(day, zone) %>%
  #filter(group != 'hr') %>%
  wilcox_test(transitions ~ group)
test_period


df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, zone, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  filter(animal != 'ctrl9') %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>%
  #filter(group != 'hr') %>%
  ggboxplot(x='group', y='transitions', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
            facet.by =  c('day', 'zone')) + ylim(0, 100) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size = 20)) +
  #stat_compare_means(label.y = 70, label.x.npc = 'left', label = 'p') +
  stat_pvalue_manual(test, label = "p", y.position = c(55,70,85)) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
                 )) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#18 Nr. of transitions over days - are stats correct here?

test_kw <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% filter(animal != 'ctrl9') %>%
  kruskal_test(transitions ~ group)
test_kw

test_wcx <- df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% filter(animal != 'ctrl9') %>%
  group_by(day) %>%
  wilcox_test(transitions ~ group)
test_wcx

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>% 
  filter(animal != 'ctrl9') %>%
  #filter(group != 'hr') %>%
  ggline(x='day', y='transitions', color = 'group', fill = 'group', size = 1, 
         add = c("mean_se"), add.params = list(alpha = 0.6, fill = 'group', size = .5)) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position="top") +
  theme(text = element_text(size=20)) +
  #stat_pvalue_manual(test_wcx, label = 'p.adj.signif', y.position = c(120,130,140)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 140, size=4) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
                 ))

#19 Nr. of transitions over days per period
df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='day', y='transitions', color = 'group', fill = 'group', size = 1, facet.by = c('period'),
         add = c("mean_se", "dotplot"), add.params = list(alpha = 0.6, fill = 'group', size = .5)) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position = 'top') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 50, size = 8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#20 Nr. of transitions over periods per day

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  filter(animal != 'ctrl9') %>% #filter(group != 'hr') %>%
  ggline(x='period', y='transitions', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), add.params = list(alpha = 0.6, fill = 'group', size = .5)) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position = 'top') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 40, size = 8) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
                 ))

#21 Nr. of transitions over periods per day - are stats correct here?

df %>% select(!c('cum_dist_cm', 'bout_velocity')) %>%
  group_by(group, animal, day, period) %>% na.omit() %>% summarise(transitions = length(bout_zone)) %>%
  ggline(x='period', y='transitions', color = 'group', fill = 'group', size = 1, facet.by = c('day'),
         add = c("mean_se", "dotplot"), add.params = list(alpha = 0.6, fill = 'group', size = .5)) +
  theme_light() + ylab('Nr. of zone transitions') + theme(legend.position = 'top') +
  theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', label.y = 50, size = 8) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))
         
# TIME IN THE ZONE ----

#1 Time spent in zone based on unfiltered counting (included)
test_time <- df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  filter(animal != 'chr8') %>%
  #filter(period == 'q1') %>% filter(period == 'q3') %>%
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(zone) %>%
  wilcox_test(cum_time_sec ~ group)
test_time


df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>% 
  ggboxplot(x='group', y='cum_time_sec', color = 'group', fill = 'group', alpha=0.5,
           facet.by = 'zone') +
  ylab('Cumulative ROI time (min)') +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(label.y = 70, size=6) +
  stat_pvalue_manual(test_time, label = 'p.adj.signif', y.position = c(50,62,56), size = 6) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21)

#2 Time spent in zone based on unfiltered counting - time averaged for each animal over 5 days 

test_time <- df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  filter(animal != 'chr8') %>%
  filter(day != 1) %>%
  #filter(period == 'q1') %>% filter(period == 'q3') %>%
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(zone) %>%
  wilcox_test(cum_time_sec ~ group)
test_time

df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'interzone') %>% 
  filter(zone != 'drinking') %>% 
  filter(period == 'q4') %>% 
  filter(animal != 'chr8') %>%
  filter(day != 1) %>%
  group_by(group, animal, zone) %>% count(zone) %>%
  group_by(group, animal, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>% mutate(mean_time = mean(cum_time_sec)) %>%
  ggboxplot(x='group', y ='cum_time_sec', color = 'group', fill = 'group', alpha=0.5, outlier.shape = NA,
            facet.by = 'zone') +
  #facet_grid(~zone, scales = 'free') +
  ylab('Cumulative ROI time (min)') +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(label.y = 150, size=4) +
  stat_pvalue_manual(test_time, label = 'p.adj.signif', y.position = c(70, 90, 110), size = 4) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  theme(legend.position = 'bottom')
  #geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) 
  
#3 Time spent in zone based on unfiltered counting - faceted by period (included)
test <- df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'drinking') %>% 
  group_by(group, animal, day, period, zone) %>% count(zone) %>%
  group_by(group, animal, day, period, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(period, zone) %>%
  wilcox_test(cum_time_sec ~ group)
test


df %>%
  filter(zone != 'unclassified') %>%
  #filter(zone != 'interzone') %>% 
  filter(zone != 'drinking') %>% 
  group_by(group, animal, day, period, zone) %>% count(zone) %>% 
  group_by(group, animal, day, period, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggboxplot(x='group', y='cum_time_sec', color = 'group', fill = 'group', alpha=0.5, outlier.shape = NA,
           facet.by = c('zone', 'period')) +
  ylab('Cumulative ROI time (min)') + ylim(0,30) +
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  stat_compare_means(size=4, label.y = 28) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(14,22,18), size = 4) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21) #+
  #geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) 

#4 time averaged per animal per 5 days - free scales
df %>%
  filter(zone != 'unclassified') %>%
  filter(zone != 'drinking') %>% 
  filter(animal != 'ctrl9') %>% filter(animal != 'chr1') %>%
  group_by(group, animal, period, zone) %>% count(zone) %>% 
  group_by(group, animal, period, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>% mutate(mean_time = mean(cum_time_sec)) %>%
  ggboxplot(x='group', y='cum_time_sec', color = 'group', fill = 'group', alpha=0.5, outlier.shape = NA) +
  facet_grid(c('zone', 'period'), 
             scales = 'free_y'
             ) +
  ylab('Cumulative ROI time (min)') + #ylim(0,70) + 
  theme_light() + theme(text = element_text(size=20)) +
  theme(axis.text.x = element_text(angle = 80, vjust = 0.5, hjust=1)) +
  stat_compare_means(size=4) +
  stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(50,60,70), size = 4) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 
  #geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) 

#5 Time spent in zone over days 
df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>%
  #filter(group != 'hr') %>%
  filter(zone != 'interzone') %>%
  filter(period != 'q2') %>% filter(period != 'q4') %>%
  filter(zone != 'drinking') %>% 
  group_by(group, animal, day, zone) %>% count(zone) %>%
  group_by(group, animal, day, zone) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggline(x='day', y='cum_time_sec', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), add.params = list(alpha=0.5),
         facet.by = c('zone')) +
  ylab('Cumulative ROI time (min)') + #ylim(0,30) +
  theme_light() + theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', size=4, label.y = 40) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde",
                 "#b0b0b0", 
                 "#dea15f"
                 ))

#6 Time spent in the zone over period

df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>% 
  group_by(group, animal, zone, day, period) %>% count(zone) %>%
  group_by(group, animal, zone, day, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggline(x='day', y='cum_time_sec', color = 'group', fill = 'group', size = 1,
         add = c("mean_se"), add.params = list(alpha=0.8),
         facet.by = c('zone', 'period')) +
  facet_grid(c('zone', 'period'), scales = 'free') +
  ylab('Cumulative ROI time (min)') + #ylim(0,13) +
  theme_light() + theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', size=4, label.y = 11) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#7 Time spent in the zone over period

df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  #filter(group != 'ctrl') %>% #filter(day == 2) %>%
  group_by(group, animal, day, zone, period) %>% count(zone) %>%
  group_by(group, animal, day, zone, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  ggline(x='period', y='cum_time_sec', color = 'group', fill ='group', size = 1, outlier.shape = NA, facet.by = 'zone',
         add = c("mean_se"), add.params = list(alpha=0.5))+
  ylab('Cumulative ROI time (min)') + #ylim(0,13) +
  theme_light() + theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', size=4, label.y = 12) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
                 )) 

#7.1 Time in the zone over period - period comparison

#across groups, within periods
test <- df %>% 
  select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  filter(period != "q2") %>% filter(period != 'q3') %>% filter(animal != 'chr8') %>% 
  filter(day != 1) %>%  
  #filter(day != 2) %>%
  filter(day != 3) %>% 
  filter(day != 4) %>% 
  filter(day != 5) %>%
  group_by(group, animal, zone, period) %>% count(zone) %>%
  group_by(group, animal, zone, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(zone, period) %>% 
  wilcox_test(cum_time_sec~group) 
test %>% 
  filter(p.adj.signif != 'ns')

# within group, across periods
test <- df %>% 
  select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  filter(period != "q2") %>% filter(period != 'q3') %>% filter(animal != 'chr8') %>% 
  filter(day != 2) %>% filter(day != 3) %>% filter(day != 4) %>%  
  group_by(group, animal, zone, period) %>% count(zone) %>%
  group_by(group, animal, zone, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  group_by(zone, group) %>% 
  wilcox_test(cum_time_sec~period) 
test %>%
  filter(p < 0.05)
  

df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% filter(zone != 'drinking') %>% 
  #filter(group != 'hr') %>% #filter(zone == 'nest') %>%
  filter(day != 1) %>% 
  filter(day != 2) %>%
  filter(day != 3) %>% 
  filter(day != 4) %>% 
  #filter(day != 5) %>%
  filter(period != "q2") %>% filter(period != 'q3') %>%
  group_by(group, animal, zone, period) %>% count(zone) %>%
  group_by(group, animal, zone, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  filter(animal != 'chr8') %>%
  ggboxplot(x='period', y='cum_time_sec', color = 'group', fill ='group', alpha = 0.5, outlier.shape = NA, 
            facet.by = 'zone', add = 'jitter')+
  ylab('Cumulative ROI time (min)') + #ylim(0,40) +
  #facet_grid('zone', scales = 'free') +
  theme_light() + theme(text = element_text(size=20)) +
  #stat_pvalue_manual(test, label = 'p.adj.signif', y.position = c(40,50,60,80), size = 4) +
  #stat_compare_means(label = 'p.signif', size=8, label.y = 50) +
  color_palette(c("#5f8cde", 
                  "#b0b0b0", 
                  "#dea15f"
  )) +
  fill_palette(c("#5f8cde", 
                 "#b0b0b0", 
                 "#dea15f"
  )) +
  theme(legend.position = 'bottom')
  #geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  #theme(legend.position = 'bottom')
  

#8 Time spent in the zone over period -  look at the stats + filter the outliers

df %>% select(!c('cum_dist_cm', 'bout_velocity', 'bout_duration')) %>% 
  filter(zone != 'unclassified') %>% filter(zone != 'interzone') %>% filter(zone != 'drinking') %>%
  filter(group != 'ctrl') %>%
  #filter(animal != 'chr1') %>%  filter(animal != 'chr3') %>% 
  group_by(group, animal, day, zone, period) %>% count(zone) %>% 
  group_by(group, animal, day, zone, period) %>% summarise(cum_time_sec=(sum(n)/30)/60) %>%
  #filter(cum_time_sec < 12.5) %>%
  ggline(x='period', y='cum_time_sec', color = 'group', fill = ' group', size = 1, outlier.shape = NA,
         add = c("mean_se"), add.params = list(alpha=0.5),
         facet.by = c('zone', 'day')) +
  facet_grid(c('zone', 'day'), scales = 'free') +
  ylab('Cumulative ROI time (min)') + #ylim(0,13) +
  theme_light() + theme(text = element_text(size=20)) +
  stat_compare_means(aes(group=group), label = 'p.signif', size=4, label.y = 20) +
  color_palette(c("#5f8cde", 
                  #"#b0b0b0", 
                  "#dea15f"
                  )) +
  fill_palette(c("#5f8cde", 
                 #"#b0b0b0", 
                 "#dea15f"
                 )) 
  #geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16)

#9 Time spent in zone based on unfiltered counting (to compare with anymaze)
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

#10 Time spent in zone based on filtered bout data
df %>% select(!c(cum_dist_cm, bout_velocity)) %>% na.omit() %>%
  filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>%
  summarize(total_sec = sum(bout_duration)) %>%
  ggboxplot(x='bout_zone', y='total_sec', fill = 'group', outlier.shape = NA) + facet_grid(~group) +
  ylab('Cumulative bout time (s)') + 
  theme_light() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  geom_point(position = position_jitter(.2), size = 1, shape = 21)

#pdf(file = 'plots.pdf' ,paper = "a4")

#BOUT DURATIONS ----

#1 Average bout durations per zone
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggboxplot(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  theme_light() + ylab('Bout duration (s)') +
  facet_grid(~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =3.9, label.x.npc = 'left') +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21)

#2 Average bout durations per zone per animal
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% filter(group == 'chr') %>%
  group_by(group, animal, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'black', outlier.shape = NA) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =2.6, label.x.npc = 'left') +
  #theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #geom_point(position = position_jitter(.2), size = 1, shape = 21) +
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) +
  theme(legend.position = 'bottom')

#3 Bout durations per zone/per opto - averaged mbd
  df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, bout_zone, opto) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(opto~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =3.62, label.x.npc = 'left') + 
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21)
  
  #4 Bout durations per zone/per opto - all bouts
   df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
    na.omit() %>% filter(bout_zone != 'unclassified') %>%
    filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% 
    ggboxplot(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
    theme_light() + ylab('Mean bout duration (s)') +
    facet_grid(opto~bout_zone) + scale_y_log10() +
    stat_compare_means(label.y =4.62, label.x.npc = 'left') + 
    stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
    color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
    fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
    geom_point(position = position_jitter(.2), size = 1, shape = 21) 
    
  
#5 Bout durations per zone/per period || get the q4 nest
df %>% select(!c(frame, time, animal, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  ggboxplot(x='group', y='bout_duration', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(period~bout_zone) + scale_y_log10() +
  stat_compare_means(label.y =4.62, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21)

#6 Bout durations per zone/per period || get the q4 nest - per animal
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>% #filter(group != 'hr') %>%
  filter(bout_zone != 'drinking') %>% #filter(bout_zone != 'interzone') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(c('period', 'bout_zone'), scales = 'free') + scale_y_log10() +
  stat_compare_means(label.y =0.2, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  theme(legend.position = 'bottom')

#7 Bout durations per zone/per period || get the q4 nest - per animal
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% filter(group == 'ctrl') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'black', outlier.shape = NA) +
  theme_light() + ylab('Mean bout duration (s)') +
  facet_grid(c('period', 'bout_zone'), scales = 'free') + scale_y_log10() +
  stat_compare_means(label.y =0.2, label.x.npc = 'left') +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) + 
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
 # geom_point(position = position_jitter(.2), size = 1, shape = 21) +
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) +
  theme(legend.position = 'bottom')

#8 Bout durations over days (shows increase)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggline(x='day', y='mbd', color = 'group', fill = 'group', size = 1,
         add = c('mean_se'), add.params = list(alpha=0.25), facet.by = 'group') +
  theme_light() + ylab('Mean bout duration (s)') +
  #stat_compare_means(label.x.npc = 'left') +
  #stat_compare_means(comparisons = day_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#9 Bout durations over days (shows increase) ***
test_bout <- df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  group_by(zone) %>% kruskal_test(mbd ~ group)
test_bout

df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>%
  ggline(x='day', y='mbd', color = 'group', fill = 'group',
         add = c('mean_se'), add.params = list(alpha=0.25), facet.by = c('bout_zone', 'period')) +
  facet_grid(c('bout_zone', 'period'), scales = 'free') +
  theme_light() + ylab('Mean bout duration (s)') +
  #stat_compare_means(label.x.npc = 'left') +
  #stat_compare_means(comparisons = day_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#10 Bout durations over days (group comparisons)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% #filter(bout_zone != 'interzone') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
           facet.by = c('bout_zone', 'day')) +
  theme_light() + ylab('Mean bout duration (s)') + scale_y_log10() +
  stat_compare_means(label.y=2.7, label.x.npc = 'left') +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21) 
 

#11 Bout durations over days (each animal in a group)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% #filter(group == 'ctrl') %>%
  group_by(group, animal, day, bout_zone) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='group', y='mbd', alpha=0.5, color = 'black', outlier.shape = NA,
            facet.by = c('bout_zone', 'day')) +
  theme_light() + ylab('Mean bout duration (s)') + scale_y_log10() +
  #stat_compare_means(label.y=4.7, label.x.npc = 'left') +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  #color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  #geom_point(position = position_jitter(.2), size = 1, shape = 21) +
  geom_point(aes(colour = factor(animal)), position = position_jitter(.2), size = 2, shape = 16) +
  theme(legend.position = 'bottom')

#12 Bout durations over days (group comparisons)
df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% #filter(group != 'hr') %>%
  group_by(group, animal, day, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>%
  ggline(x='period', y='mbd', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA, size = 1.1,
         add = c('mean_se'), add.params = list(alpha=0.25), facet.by = c('bout_zone', 'day')) +
  facet_grid(c('bout_zone', 'day'), scales = 'free') +
  theme_light() + ylab('Mean bout duration (s)') + #scale_y_log10() +
  #stat_compare_means(aes(group=group), label.y=1000, label = '..p.signif..', label.x.npc = 'left') +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#12.1 Bout durations per period

#test within groups per period (ChR vs HR)
test <- df %>% 
  select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% 
  #filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>% 
  group_by(bout_zone, period) %>% 
  wilcox_test(mbd~group) 
test %>% 
  filter(p.adj.signif != 'ns')

#test across periods (q1 vs q4)
test2 <- df %>% 
  select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% 
  #filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>% 
  group_by(bout_zone, group) %>% 
  wilcox_test(mbd~period) 
test2 %>% 
  filter(p < 0.05)

df %>% select(!c(frame, time, cum_dist_cm, bout_velocity)) %>% 
  na.omit() %>% filter(bout_zone != 'unclassified') %>%
  filter(bout_zone != 'drinking') %>% filter(bout_zone != 'interzone') %>% 
  #filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>%
  group_by(group, animal, bout_zone, period) %>% summarise(mbd = mean(bout_duration)) %>%
  ggboxplot(x='period', y='mbd', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA,
         facet.by = 'bout_zone', add = 'jitter') +
  #facet_grid(c('bout_zone'), scales = 'free') +
  theme_light() + ylab('Mean bout duration (s)') + #scale_y_log10() +
  #stat_compare_means(aes(group=group), label.y=1000, label = '..p.signif..', label.x.npc = 'left') +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#LOCOMOTION ----

# Total locomotion

#1 overall locomotion - all animals all days
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(!is.infinite(locomotion)) %>%
  #filter(locomotion < 200) %>%
  ggboxplot(x='group', y='locomotion', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 420, label.x.npc = 'left', size=8) +
  #stat_pvalue_manual(test, label ='p.adj.signif', y.position = c(300, 350, 325), size=8) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 1, shape = 21) 

#2 overall locomotion - animals averaged
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>% 
  #filter(day == 1) %>%
  filter(!is.infinite(locomotion)) %>%
  #filter(locomotion < 300) %>%
  summarise(mean_loco = mean(locomotion)) %>%
  ggboxplot(x='group', y='mean_loco', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 420, label.x.npc = 'left', size=8) +
  #stat_pvalue_manual(test, label ='p.adj.signif', y.position = c(300, 350, 325), size=8) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 

#3 overall locomotion - animals averaged / per opto
df %>% group_by(group, animal, opto) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(!is.infinite(locomotion)) %>%
  #filter(locomotion < 300) %>%
  ggboxplot(x='group', y='locomotion', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  facet_grid(~opto) +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 600, label.x.npc = 'left', size=5) +
  #stat_pvalue_manual(test, label ='p.adj.signif', y.position = c(300, 350, 325), size=8) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 


#4 overall locomotion - animals averaged
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 300) %>%
  group_by(group, animal, day) %>%
  summarise(mean_loco = mean(locomotion)) %>%
  ggboxplot(x='group', y='mean_loco', alpha=0.5, color = 'group', fill = 'group', outlier.shape = NA) +
  facet_grid(~day) +
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) +
  stat_compare_means(label.y = 300, label.x.npc = 'left', size=3) +
  #stat_pvalue_manual(test, label ='p.adj.signif', y.position = c(300, 350, 325), size=8) +
  #stat_compare_means(comparisons = group_comparisons,
                     #aes(method = 'wilcox.test', label = ..p.signif..))  +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 


# ignore
#5 Total locomotion per animal
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  ggboxplot(x='animal', y='locomotion', color='group',
            add = 'jitter') +
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

# ignore
#6 Total locomotion over days
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 150) %>%
  ggline(x='day', y='locomotion', color='group', size = 1.2,
         add = c('mean_se', 'jitter'), facet.by = 'group') + 
  theme_light() + ylab('Cumulative locomotion (m)') + ylim(0, 260) +
  #stat_compare_means(label.y = 300) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#7 Total locomotion over days per group

df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 150) %>%
  ggline(x='day', y='locomotion', color='group', fill='group', size = 1,
         add = c('mean_se'), add.params = list(alpha=0.8)) + 
  theme_light() + ylab('Cumulative locomotion (m)') +
  theme(text = element_text(size=20)) + ylim(0, 260) +
  #stat_compare_means(aes(group=group), size=8, label = 'p.signif') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#8 Total locomotion over days per group

df %>% group_by(group, animal, period, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE) - min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(!is.infinite(locomotion)) %>% 
  #filter(locomotion < 120) %>% 
  group_by(group, animal, period, day) %>%
  ggline(x='period', y='locomotion', color='group', size = 1, add = c('mean_se')) + 
  theme_light() + ylab('Cumulative locomotion (m)') + 
  theme(text = element_text(size=20)) + 
  stat_compare_means(aes(group=group), size=8, label = 'p.signif', label.y = 30) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')


#9 Total locomotion over days per animal
df %>% group_by(group, animal, day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(!is.infinite(locomotion)) %>%
  ggline(x='day', y='locomotion', color='group', alpha=1, fill='group', size = 1.3) + 
  facet_grid(~animal) +
  theme_light() + ylab('cumulative locomotion (m)') +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f"))

#10 Total locomotion per period
df %>% group_by(group, animal, day, period) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 300) %>%
  ggboxplot(x='group', y='locomotion', color='group', fill='group', alpha=0.5, outlier.shape = NA) + 
  theme_light() +
  facet_grid(~period) + ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 200) +
  stat_compare_means(comparisons = group_comparisons,
                     aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 

#11 Total locomotion per period averaged animals
df %>% group_by(group, animal, period) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  group_by(group, animal, period) %>%
  filter(!is.infinite(locomotion)) %>%
  #filter(locomotion < 120) %>%
  mutate(mean_loco = mean(locomotion)) %>%
  ggboxplot(x='group', y='mean_loco', color='group', fill='group', alpha=0.5, outlier.shape = NA) + 
  theme_light() + facet_grid(~period) + 
  ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 220) +
  stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) 

#12 Total locomotion per day averaged animals
df %>% group_by(group, animal,day) %>%
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  group_by(group, animal, day) %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 150) %>%
  mutate(mean_loco = mean(locomotion)) %>%
  ggboxplot(x='group', y='mean_loco', color='group', fill='group', alpha=0.5, outlier.shape = NA, facet.by = 'day') + 
  theme_light() + facet_grid(~day) + 
  ylab('Cumulative locomotion (m)') +
  stat_compare_means(label.y = 300) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  geom_point(position = position_jitter(.2), size = 2, shape = 21) +
  theme(legend.position = 'bottom')

#13 Total locomotion per day averaged animals
df %>% group_by(group, animal, period, day) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(group != 'hr') %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(group, animal, day) %>%
  ggline(x='period', y='locomotion', color='group', fill='group', facet.by = 'day',
         add = c("mean_se"), add.params = list(alpha=0.5), size = 1) + 
  theme_light() + 
  ylab('Cumulative locomotion (m)') +
  #stat_compare_means(label.y = 100) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#13.1 Total locomotion per day averaged animals
df %>% group_by(group, animal, period, zone, day) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>%
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>%
  filter(group != 'hr') %>%
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(group, animal, zone, day) %>%
  ggline(x='period', y='locomotion', color='group', fill='group', facet.by = 'zone',
         add = c(("mean_se"), 'jitter'), add.params = list(alpha=0.5), size = 1) + 
  theme_light() + 
  ylab('Cumulative locomotion (m)') +
  #stat_compare_means(label.y = 100) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#14 Total locomotion per day averaged animals

#across groups, within periods
test <- df %>% group_by(group, animal, period, zone) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>% 
  filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>% 
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(zone, period) %>% 
  wilcox_test(locomotion~group) 
test %>% 
  filter(p < 0.05)

# within group, across periods
test <- df %>% group_by(group, animal, period, zone) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>% 
  filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>% 
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(zone, group) %>% 
  wilcox_test(locomotion~period) 
test %>% 
  filter(p < 0.05)

df %>% group_by(group, animal, period, zone) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>% 
  filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>% 
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(group, animal, zone) %>%
  ggboxplot(x='period', y='locomotion', color='group', fill='group', alpha=0.5, outlier.shape = NA, facet.by = 'zone',
            add = 'jitter') + 
  theme_light() + 
  ylab('Cumulative locomotion (m)') +
  #stat_compare_means(label.y = 100) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')

#15 Total locomotion per day averaged animals - per day
#across groups, within periods
test <- df %>% group_by(group, animal, period, zone, day) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>% 
  filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>% 
  filter(!is.infinite(locomotion)) %>%
  filter(locomotion < 70) %>%
  group_by(zone, period, day) %>% 
  wilcox_test(locomotion~group) 
test %>% 
  filter(p < 0.05)

df %>% group_by(group, animal, period, zone, day) %>% 
  summarise(locomotion = (max(cum_dist_cm, na.rm=TRUE)-min(cum_dist_cm, na.rm=TRUE))/100) %>% 
  filter(zone != 'drinking') %>% filter(zone != 'unclassified') %>% filter(zone != 'eating') %>%
  filter(group != 'hr') %>%
  filter(period != 'q2') %>% filter(period != 'q3') %>% 
  filter(!is.infinite(locomotion)) %>%
  #filter(locomotion > 40) %>%
  filter(day == 1) %>%
  group_by(group, animal, zone, day) %>%
  ggboxplot(x='period', y='locomotion', color='group', fill='group', alpha=0.5, outlier.shape = NA, facet.by = 'zone',
            add = 'jitter') + 
  theme_light() + 
  ylab('Cumulative locomotion (m)') +
  #stat_compare_means(label.y = 100) +
  #stat_compare_means(comparisons = group_comparisons, aes(method = 'wilcox.test', label = ..p.signif..)) +
  color_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  fill_palette(c("#5f8cde", "#b0b0b0", "#dea15f")) +
  theme(legend.position = 'bottom')


#SPEED ----

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