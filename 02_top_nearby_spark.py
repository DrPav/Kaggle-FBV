# -*- coding: utf-8 -*-
"""
Created on Thu May 26 19:46:22 2016

@author: David
"""
#Places needs to be broadcast
from pyspark import SparkConf, SparkContext
import pandas as pd
import datetime as dt

conf = SparkConf().setMaster("local[*]").setAppName("FriendsByAge")
sc = SparkContext(conf = conf)

places_filepath = "data/01_places.csv"
test_set_filepath = "data/01_test_860kobs.csv"

distance = 2
x_range = 0.77*distance
y_range = 0.03*distance

def load_csv(filepath):
    data = sc.textFile(filepath)
    header = data.first() #extract header
    print header
    data = data.filter(lambda x:x !=header)    #filter out header
    return data


def map_test_data(line):
    fields = line.split(",")
    row_id = fields[0]
    x = float(fields[1])
    y = float(fields[2])
    return (row_id, (x,y))


def getTop3(test_row):
    (row_id, (x, y)) = test_row
 
    p = places.value
    x_test = (p['x'] < x + x_range) & (p['x'] > x - x_range)
    y_test = (p['y'] < y + y_range) & (p['y'] > y - y_range)
    p = p[x_test & y_test].sort_values(by = 'count')
    top3 = p[0:3]['place_id'].tolist()
    
    return (row_id, top3)
    

places_data = pd.read_csv(places_filepath)

places = sc.broadcast(places_data)
#Format is (Place_id, (x, y, popularity))
print places.value[0:1]

test_data = load_csv(test_set_filepath).map(map_test_data)
print test_data.first()
time1 = dt.datetime.now()
top_3_out = test_data.map(getTop3).collect()
time2 = dt.datetime.now()
time_elapsed = time2 - time1
print(time_elapsed)
#Calculation took 29 seconds
#5x faster than r
#200k took 10 minutes
f = open('data/02_output_full.csv', 'w')
for row in top_3_out:
    row_id, top_places = row
    s = (row_id + "," + 
        str(top_places[0])  + "," +
        str(top_places[1])  + "," +
        str(top_places[2]) + "\n" )
    f.write(s)
        
f.close()

#cartesian_product = places.cartesian(test_data)
#places_in_range = cartesian_product.filter(find_nearby)

#print places_in_range.count()