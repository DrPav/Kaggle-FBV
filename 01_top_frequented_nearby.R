#Find the top 3 visited places in range of the xy co-ords
require(data.table)
require(dplyr)
require(magrittr)
require(bit64)


raw_train = fread("data/train.csv", integer64 = "character")
# Get errors later on when joining on placeID that is integer64.
#Use "Character" instead as it is only a key
#Use as.data.frame to get rid of errors when joining saying its not a dataframe

#For each place take the average co-ordinates and number of times visited
places = raw_train %>% group_by(place_id) %>%
  summarise(x = mean(x), y = mean(y), count = n()) %>%
  as.data.frame()

#Turn below into function (x_coord, y_coord, distance)
#testing

#Get the places in range
distance = 2
x_range = 0.77*distance
y_range = 0.03*distance

getTop3 <- function(x_coord, y_coord){

in_range = places %>% filter(x < x_coord + x_range,
                             x > x_coord - x_range,
                             y < y_coord + y_range,
                             y > y_coord - y_range)
top_3 = arrange(in_range, desc(count))[1:3,]
return(top_3$place_id)
}

test_set = fread("data/test.csv")
test_set_small = test_set[1:10000,] %>% select(row_id, x,y)

print("Start")
a = Sys.time()
print(a)
results = apply(test_set_small %>% as.matrix(), 1, function(r) getTop3(r['x'],r['y'])) %>% t()
results_named = cbind(select(test_set_small, row_id), results)
b = Sys.time()
print(b)
print("End 10000 done")
print(b-a)
# 1,000 takes 14 seconds
# 10,000 takes 149 seconds
# Estimate that all 8 Millio will take 33 hours - doing 250,000 an hour

#Very slow
#Export the data sets and try in Python
write.csv(places, "data/01_places.csv", row.names = F)
write.csv(test_set_small, "data/01_test_10kobs.csv", row.names = F)
write.csv(select(test_set, row_id, x, y), "data/01_test_860kobs.csv", row.names = F)

test_set1 = test_set[1:200000,] %>% select(row_id, x,y)
write.csv(select(test_set1, row_id, x, y), "data/01_test_p1.csv", row.names = F)

test_set2 = test_set[200000:400000,] %>% select(row_id, x,y)
write.csv(select(test_set2, row_id, x, y), "data/01_test_p2.csv", row.names = F)

test_set3 = test_set[400000:600000,] %>% select(row_id, x,y)
write.csv(select(test_set3, row_id, x, y), "data/01_test_p3.csv", row.names = F)

test_set4 = test_set[600000:8607230, ] %>% select(row_id, x,y)
write.csv(select(test_set4, row_id, x, y), "data/01_test_p4.csv", row.names = F)

#Create an artifical test set of only 100*100 points across space. 
#Then map the actual test values to closest answer in the artificial space
x_points = seq(from =0, to = 10, length.out = 100 )
y_points = seq(from = 0, to = 10, length.out = 1000)

x = numeric()
y = numeric()
counter = 1
for(x_value in x_points){
  for(y_value in y_points){
    x[counter] = x_value
    y[counter] =  y_value
    counter = counter + 1
  }
}

test_artificial = data.frame(id = 1:100000, x, y)
write.csv(test_artificial, "data/01_test_grid.csv", row.names = F)


