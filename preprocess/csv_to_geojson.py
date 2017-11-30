""" Need to convert CSV file to GeoJson. 

Reference: https://www.zillow.com/howto/api/neighborhood-boundaries.htm
"""
import csv
from random import randint, seed

import geojson
from geojson import Polygon, FeatureCollection, Feature

seed(42)

def read_csv(fpath):
    with open(fpath, "r") as infile:
        reader = csv.DictReader(infile)
        for row in reader:
            yield row


def write_geojson(feature_collection, outpath):
    with open(outpath, "w") as outfile:
        geojson.dump(feature_collection, outfile)


def geojson_feature2_collection(rows):
    poly = []
    features = []
    grp = ""
    for row in rows:
        if row['group'] != grp:
            f = Feature(geometry=Polygon([poly]),
                        id = row['id'],
                        properties={"group": row["group"],
                                    "density": randint(1,100)})
            features.append(f)
            # reset
            poly = []
            grp = row['group']
            poly.append((float(row['long']),
                         float(row['lat'])))

        else:
            poly.append((float(row['long']),
                         float(row['lat'])))

    f = FeatureCollection(features)
    return f


################ Run commands ###########################

rows = read_csv("data/coordinates.csv")
fcollection = geojson_feature2_collection(rows)

write_geojson(fcollection, "data/sumedh-boston.geojson")
