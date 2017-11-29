""" Encode data from CSV file into geojson """
from preprocess.identify_hull import (geojson_feature_collection,
                                      write_geojson)


fcollection = geojson_feature_collection(
    fpath="data/openaddress/city_of_boston.csv",
    zipname="POSTCODE", latname="LAT", lngname="LON")

#TODO: Unable to compute convex hull: 02133
#TODO: Unable to compute convex hull: (blank)

write_geojson(fcollection, "data/us-boston.geojson")


