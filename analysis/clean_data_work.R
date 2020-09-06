library(tidyverse)

df <-read_csv(r"{J:\Alja Podgornik\Multimaze arena\Cohort 1_June 2020\all_videos\processed\withROIs\cleaned\combined.csv}")


acum<-acum %>% 
  dplyr::select(-X1,-drinking, -social, -marble, -nest, -black_circle)



acum<- acum %>% 
  dplyr::filter(zone != "exit1" ,
                zone != "exit2" ,
                zone != "exit3") 
test<- acum[1:100,]

# command to replace this at a later time for exit issue
# test %>% 
#   mutate(new_col = str_replace(zone, "exit1", "eating"))

save<-acum



animal_split<-acum %>% 
  dplyr::group_split(animal,day) 


rle_vals <-lapply(animal_split, custom_rle_fun)



custom_rle_fun <- function(x){
  zone_hold<-rle(x$zone)
  return(zone_hold)
}


return_df<-function(y){
df <- data.frame("zone" = y$values,
               "frames" = y$lengths)
return(df)
}


rle_df<-lapply(rle_vals, return_df)


for(i in 1:length(rle_df)){
  rle_df[[i]]$animal <-unique(animal_split[[i]]$animal)
  rle_df[[i]]$group <-unique(animal_split[[i]]$group)
  rle_df[[i]]$day <-unique(animal_split[[i]]$day)
}



hold2<-(rle_df[[1]])

unique(hold2$zone)

adding_stim<-function(z) {
  df2 <-z %>% 
    mutate(cum_sum = cumsum(frames)) %>%  
    mutate(stim = case_when(
      cum_sum / 30 < (15*60) ~ "stim1", 
      cum_sum / 30 >= (15*60) &
        cum_sum / 30 < (30*60) ~ "ref_1",
      cum_sum / 30 >= (30*60) &
        cum_sum / 30 < (45*60) ~ "stim2", 
      cum_sum / 30 >= (45*60) ~ "ref2"
    ))
  
  return(df2)
}

rle_df_stim <-lapply(rle_df, adding_stim)


comb<-bind_rows(rle_df_stim)

install.packages("ggpubr")
library(ggpubr)
ggpubr::

my_comparisons <- list( c("chr", "ctrl"), c("chr", "hr"), c("ctrl", "hr") )


ggboxplot(df, x = "dose", y = "len",
          color = "dose", palette =c("#00AFBB", "#E7B800", "#FC4E07"),
          add = "jitter", shape = "dose")


# time spent in each area, testing categories against each other 
# stimulation period
comb %>% 
  dplyr::filter(frames > 30 ) %>%
  dplyr::filter(zone == "nest" |
                  zone == "social") %>% 
  ggboxplot(., x = "group", 
            y = "frames", 
            color = "group", 
            alpha = 0.5) +
  scale_y_log10() +
  stat_compare_means(comparisons = my_comparisons, 
                     method = "t.test", 
                     label.y = c(3.3,3.0,3.5), 
                     p.adjust.methods = "bonferroni") +
  facet_grid(zone~stim)

  # facet_grid(.~zone) +
  # scale_y_log10() +
  stat_compare_means(comparisons = my_comparisons, 
                     label = "p.signif", 
                     p.adjust.methods = "BH")                  


  

  
  my_comp2<-list(c("stim1" ,"ref_1"), c("stim1", "stim2"), 
  c("stim1" , "ref2"), c("ref_1", "ref2"), 
  c("stim2", "ref2"), c("stim2", "ref_1"))
  

  comb %>% 
    dplyr::filter(frames > 30 ) %>%
    dplyr::filter(zone == "nest") %>% 
    ggboxplot(., x = "stim", 
              y = "frames", 
              color = "group", 
              alpha = 0.5) +
    scale_y_log10() +
    stat_compare_means(comparisons = my_comp2, 
                       method = "t.test") +
    facet_grid(zone~group)
  