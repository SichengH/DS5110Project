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

def read_tsv(fpath):
    with open(fpath, "r") as infile:
        reader = csv.reader(infile, delimiter = "\t")
        for row in reader:
            yield row


def write_geojson(feature_collection, outpath):
    with open(outpath, "w") as outfile:
        geojson.dump(feature_collection, outfile)


def parse_zillow_coordinates(coord_col):
    here = []
    for coord_pair in coord_col.split(","):
        these = coord_pair.split(";")
        here.append((float(these[0]), float(these[1])))
    return here

def geojson_zillow_fc(rows):
    """ Need a conversion for Zillow shapefiles. """
    feature_collection = []
    for row in rows:
        if row[2] == "Boston":
            f = Feature(geometry=Polygon(\
                                [parse_zillow_coordinates(row[6])]),
                                id = row[4],
                                properties={"state": str(row[0]),
                                            "county": str(row[1]),
                                            "city": str(row[2]),
                                            "neighborhood": \
                                            str(row[3]),
                                            "regionid": str(row[4]),
                                            "total_potins": \
                                            str(row[5]),
                                            "mean_interior_score": \
                                            row[7],
                                            "sd_interior_score":\
                                            row[8],
                                            "max_int_score":\
                                            row[9],
                                            "min_int_score":\
                                            row[10],
                                            "region_property_count":\
                                            row[11]
                                })
            feature_collection.append(f)

        else:
            print("City: {}".format(row[2]))

    fc = FeatureCollection(feature_collection)
    return fc


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

#rows = read_csv("data/coordinates.csv")
#fcollection = geojson_feature2_collection(rows)

#write_geojson(fcollection, "data/sumedh-boston.geojson")


#rows = read_tsv(fpath = "data/MA-Regions.csv")
#fcollection = geojson_zillow_fc(rows)

#write_geojson(fcollection, "data/zillow-conversion-boston.geojson")


#rows = read_tsv(fpath = "data/regionsdf.csv")
#fcollection = geojson_zillow_fc(rows)

#write_geojson(fcollection, "data/zillow-conversion-boston2.geojson")



