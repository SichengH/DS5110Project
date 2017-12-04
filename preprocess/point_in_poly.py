import geojson
import json
import csv
from shapely.geometry import shape, Point

# open the geojson file
with open('../data/zillow-conversion-boston.geojson') as geofile:
    geo = json.load(geofile)

# open file to write 
writer = csv.writer(open('../data/points_new.csv', 'w'))

# open points file
with open('../data/points_sample.csv') as pcsv:
    reader = csv.reader(pcsv) 
    row = next(reader) # skip header
    for row in reader:
        p = Point(float(row[2]), float(row[1])) # create point
        for feature in geo['features']: # for each polygon, check if p in polygon
            polygon = shape(feature['geometry'])
            if polygon.contains(p):
                writer.writerow([row[2], row[1], feature['properties']['regionid'], feature['properties']['neighborhood']])
                break
