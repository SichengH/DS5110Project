""" Need to create outer hulls for Polygon in GeoJson. 

DO NOT USE. This was an experiment that didn't go well because of
dirty data.
"""
print(__doc__)
from collections import defaultdict
import csv
from random import randint, seed

from numpy import matrix
from scipy.spatial import ConvexHull
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

def parse_zip(rows, zipname, latname, lngname):
    """ Create a collection of points for each zipcode. """
    zipcodes = defaultdict(list)
    for row in rows:
        zipcode = row[zipname]
        try:
            zipcodes[zipcode].append([float(row[latname]),
                                      float(row[lngname])])
        except ValueError:
            print("Unable to add zipcode: {}".format(zipcode))

    return zipcodes


def compute_convex_hull(zipcode, points):
    """ Compute a convex hull, given a list of points and a zipcode. """
    geo_points = matrix(points)
    hull = ConvexHull(geo_points)
    
    lng = geo_points[hull.vertices,0]
    lat = geo_points[hull.vertices,1]
    return (zipcode, lat, lng)


def geojson_feature(chull: tuple):
    zipcode, lat, lng = chull
    poly = []
    assert len(lat) == len(lng)
    for rownum in range(len(lat)):
        poly.append((lat[rownum][0,0],
                     lng[rownum][0,0]))

    f = Feature(geometry=Polygon([poly]),
                id=zipcode,
                properties={"zipcode": zipcode,
                            "density": randint(1,100)})
    return f
                

def geojson_feature_collection(fpath, zipname, latname, lngname):
    features = []
    rows = read_csv(fpath)
    zipcodes = parse_zip(rows, zipname, latname, lngname)
    for zipcode in zipcodes.keys():

        try:
            chull = compute_convex_hull(zipcode, zipcodes[zipcode])

        except:
            print("Unable to compute convex hull: {}".format(zipcode))

        feature = geojson_feature(chull)
        features.append(feature)

    f = FeatureCollection(features)
    return f





    


        
