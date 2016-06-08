#Create a subset of the data for testing
require(data.table)
require(dplyr)
require(magrittr)
require(bit64)

raw_train = fread("data/train.csv", integer64 = "character")  %>% as.data.frame()
raw_test = fread("data/test.csv", integer64 = "character")  %>% as.data.frame()
# Get errors later on when joining on placeID that is integer64.
#Use "Character" instead as it is only a key
#Use as.data.frame to get rid of errors when joining saying its not a dataframe

train_subset = raw_train %>% filter(x <1.25, y<1.25)
test_subset = raw_test %>% filter(x <1.25, y<1.25)

#Percent of total data
length(train_subset$x)/length(raw_train$x)
#1.5%

write.csv(train_subset, "data/04_train_subset.csv", row.names = F)
write.csv(test_subset, "data/04_test_subset.csv", row.names = F)