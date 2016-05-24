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
test_set_small = test_set[1:10000,] %>% select(row_id, x,y) %>% as.matrix()

print("Start")
a = Sys.time()
print(a)
results = apply(test_set_small, 1, function(r) getTop3(r['x'],r['y'])) %>% t()
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
write.csv(places, "data/01_places.csv")
