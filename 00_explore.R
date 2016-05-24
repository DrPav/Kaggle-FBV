#Script looking at accuracy
require(data.table)
require(dplyr)
require(magrittr)
require(bit64)
require(ggplot2)


raw = fread("data/train.csv", integer64 = "character")  %>% as.data.frame()
# Get errors later on when joining on placeID that is integer64.
#Use "Character" instead as it is only a key
#Use as.data.frame to get rid of errors when joining saying its not a dataframe

grouped = raw %>% group_by(place_id) %>% 
  summarise(accuracy_sd = sd(accuracy), place_count = n()) %>% 
  as.data.frame() %>% arrange(accuracy_sd) 

#Need to look at a good cutoff to use for place_count
with(sample_n(grouped, 2000), plot(place_count, accuracy_sd))

grouped_filtered = grouped %>% filter(accuracy_sd < 40, place_count < 100)

with(grouped_filtered, plot(place_count, accuracy_sd))

#Choose the sample
consistent_accuracy = filter(grouped, accuracy_sd < 18, place_count > 12 )

with(consistent_accuracy, plot(place_count, accuracy_sd))

#Have about 100 observations for analysis
#Select these palces from the original dataset

new_df = inner_join(raw, consistent_accuracy)
#Calculate the variation in x, y and time 
#Warning time is in minutes

final_df = new_df %>% group_by(place_id) %>% summarise(x_sd = sd(x), y_sd = sd(y), accuracy_mean = mean(accuracy), time_sd = sd(time)) %>%
  as.data.frame()


#Explore relationships with the new_df
attach(final_df)
plot(accuracy_mean, x_sd)
plot(accuracy_mean, y_sd)
plot(accuracy_mean, time_sd)
detach(final_df)
#No obvious relationships

#Sort by the most popular check-ins to analyse the spread of x and y
df1 = arrange(grouped, desc(place_count))
df2 = df1[1:5,] # Top 5 locations
df3 = inner_join(raw, df2) # All checkins at top 5 locations
plot(df3$x, df3$y)
#Is distribution uniform
hist(filter(df3, place_id == "8772469670")$y, breaks = 20)
#Yes
#Calcuate the x and y standard deviation for the top 5
df4 = df3 %>% group_by(place_id) %>% summarise( y.sd = sd(y), x.sd = sd(x), y.mean = mean(y), x.mean = mean(x)) %>% 
  as.data.frame()
df4
df4$xplus = df4$x.mean + 2 
#Average 95% y range
mean(df4$y.sd)*2
# 0.0286
# 0.03
#Average 95% x range
mean(df4$x.sd)*2
# 0.768
# 0.77


#Calculate the centroid for each

centroids = raw %>% group_by(place_id) %>% summarise(x.average = mean(x), y.average = mean(y)) %>% as.data.frame()
plot(centroids$x.average, centroids$y.average)

#if randomly distributed, how many are in a average 2sd*2sd square. Use bottom left of grid
length(filter(centroids, x.average < 0.77*2 & y.average < 0.03*2)$place_id)
# 80, Each point can have about 80 location options

#Does accuracy incrase over time?
#Investigate for top 2
#"8772469670", "1623394281"
df5 = raw %>% filter(place_id == "8772469670" ) %>% arrange(time)
plot(df5$time, df5$accuracy)
#NO

