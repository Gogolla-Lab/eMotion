library(tidyverse)
library(rstatix)
library(ggpubr)

df <- read_csv(r"{C:\Users\serce\Desktop\combined.csv}")
df <- df %>% dplyr::rename('frame' = 'X1')
df$group <- as.factor(df$group)
df$day <- as.factor(df$day)
df$period <- as.factor(df$period)

### Day1 ###

day1 <- df %>% dplyr::filter(day==1)

# Time in the zones
day1 %>% filter(zone != 'unclassified') %>%
  group_by(group, animal, zone) %>% count(zone) %>%
  group_by(group, animal, zone) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggboxplot(x='group', y='cum_time_sec', fill='group', add = 'jitter',
            facet.by = c('zone'), scales="free") +
  stat_compare_means()

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  group_by(group, animal, zone, period) %>% count(zone) %>%
  group_by(group, animal, zone, period) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggboxplot(x='group', y='cum_time_sec', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone', 'period'), scales="free") +
  theme(legend.position = 'none')

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  group_by(group, animal, zone, opto) %>% count(zone) %>%
  group_by(group, animal, zone, opto) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggboxplot(x='group', y='cum_time_sec', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone', 'opto'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='chr') %>%
  group_by(group, animal, zone, opto) %>% count(zone) %>%
  group_by(group, animal, zone, opto) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggboxplot(x='opto', y='cum_time_sec', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='hr') %>%
  group_by(group, animal, zone, opto) %>% count(zone) %>%
  group_by(group, animal, zone, opto) %>% summarise(cum_time_sec_hr=sum(n)/30) %>%
  ggboxplot(x='opto', y='cum_time_sec_hr', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='ctrl') %>%
  group_by(group, animal, zone, opto) %>% count(zone) %>%
  group_by(group, animal, zone, opto) %>% summarise(cum_time_sec_ctrl=sum(n)/30) %>%
  ggboxplot(x='opto', y='cum_time_sec_ctrl', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='ctrl') %>%
  group_by(group, animal, zone, opto, period) %>% count(zone) %>%
  group_by(group, animal, zone, opto, period) %>% summarise(cum_time_sec_ctrl=sum(n)/30) %>%
  ggboxplot(x='period', y='cum_time_sec_ctrl', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='hr') %>%
  group_by(group, animal, zone, opto, period) %>% count(zone) %>%
  group_by(group, animal, zone, opto, period) %>% summarise(cum_time_sec_hr=sum(n)/30) %>%
  ggboxplot(x='period', y='cum_time_sec_hr', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)

day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=='chr') %>%
  group_by(group, animal, zone, opto, period) %>% count(zone) %>%
  group_by(group, animal, zone, opto, period) %>% summarise(cum_time_sec_chr=sum(n)/30) %>%
  ggboxplot(x='period', y='cum_time_sec_chr', fill='group',
            add = 'jitter', 
            add.params = list(color = 'animal'),
            facet.by = c('zone'), scales="free") +
  theme(legend.position = 'none') +
  stat_compare_means(label.y.npc = 0.88)


# ChR
day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=="chr") %>%
  group_by(animal, zone, period) %>% count(zone) %>%
  group_by(animal, zone, period) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggbarplot(x='animal', y='cum_time_sec', fill = 'animal',
            facet.by=c('zone', 'period')) + coord_flip()

# HR
day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=="hr") %>%
  group_by(animal, zone, period) %>% count(zone) %>%
  group_by(animal, zone, period) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggbarplot(x='animal', y='cum_time_sec', fill = 'animal',
            facet.by=c('zone', 'period')) + coord_flip()

# Ctrl
day1 %>% filter(zone != 'unclassified') %>% filter(zone != 'drinking') %>%
  filter(group=="ctrl") %>%
  group_by(animal, zone, period) %>% count(zone) %>%
  group_by(animal, zone, period) %>% summarise(cum_time_sec=sum(n)/30) %>%
  ggbarplot(x='animal', y='cum_time_sec', fill = 'animal',
            facet.by=c('zone', 'period')) + coord_flip()



# Locomotion

day1 %>% select(!c(bout_duration, bout_zone, bout_velocity)) %>%
  na.omit() %>% group_by(group, animal, day) %>%
  summarise(loco=(max(cum_dist_cm))/100) %>%
  ggboxplot(x='group', y='loco', fill = 'group', add = 'jitter',
            add.params = list(color = 'animal')) +
  theme(legend.position = 'none')

day1 %>% select(!c(bout_duration, bout_zone, bout_velocity)) %>%
  na.omit() %>% group_by(group, animal, day, opto) %>%
  summarise(loco=(max(cum_dist_cm) - min(cum_dist_cm))/100) %>%
  ggboxplot(x='opto', y='loco', fill = 'group', add = 'jitter',
            add.params = list(color = 'animal'),
            facet.by = 'group') +
  stat_compare_means() +
  theme(legend.position = 'none')

day1 %>% select(!c(bout_duration, bout_zone, bout_velocity)) %>%
  na.omit() %>% group_by(group, animal, day, period) %>%
  summarise(loco=(max(cum_dist_cm)-min(cum_dist_cm))/100) %>%
  ggboxplot(x='period', y='loco', fill = 'group', add = 'jitter',
            add.params = list(color = 'animal'),
            facet.by = 'group') +
  stat_compare_means() +
  theme(legend.position = 'none')

## Nr. of transitions

day1 %>% select(!c(bout_velocity)) %>% na.omit() %>%
  group_by(group, animal, day) %>%
  summarise(transitions=length(bout_zone)) %>%
  ggboxplot(x="group", y="transitions", fill="group",
            add = 'jitter',
            add.params = list(color = 'animal')) +
  theme(legend.position = "none") +
  stat_compare_means()

day1 %>% select(!c(bout_velocity)) %>% na.omit() %>%
  group_by(group, animal, day, opto) %>%
  summarise(transitions=length(bout_zone)) %>%
  ggboxplot(x="opto", y="transitions", fill="group",
            add = 'jitter',
            add.params = list(color = 'animal'),
            facet.by = 'group') +
  theme(legend.position = "none") +
  stat_compare_means()


day1 %>% select(!c(bout_velocity)) %>% na.omit() %>%
  group_by(group, animal, day, period) %>%
  summarise(transitions=length(bout_zone)) %>%
  ggboxplot(x="period", y="transitions", fill="group",
            add = 'jitter',
            add.params = list(color = 'animal'),
            facet.by = 'group') +
  theme(legend.position = "none") +
  stat_compare_means()

df %>% filter(day != 2) %>% filter(day != 4) %>%
  select(!c(bout_velocity)) %>% na.omit() %>%
  group_by(group, animal, day, period) %>%
  summarise(transitions=length(bout_zone)) %>%
  ggboxplot(x="period", y="transitions", fill="group",
            add = 'jitter',
            add.params = list(color = 'animal'),
            facet.by = c('group', 'day')) +
  theme(legend.position = "none") +
  stat_compare_means()


