""" Geocode each city. """
import csv
import logging
import os
import googlemaps

logging.basicConfig(filename='google_places.log',level=logging.INFO,
                    format='%(asctime)s %(levelname)s:%(message)s',
                    datefmt='%m/%d/%Y %I:%M:%S %p')

logging.info("Starting google places API script.")

gmaps = googlemaps.Client(key=os.getenv("GGL_PLACE"))

nrequests = 1

with open('data/bos_addr_coords.csv', 'w') as outfile:
    fieldnames = ['search_addr', 'lat', 'lng', 'CONCAT_PID', 'n']
    writer = csv.DictWriter(outfile, fieldnames = fieldnames, quotechar='"')
    writer.writeheader()
    
    with open('data/consol_bad_addr.csv', 'r') as infile:
        reader = csv.DictReader(infile)

        for row in reader:

            if nrequests % 1000 == 0:
                logging.info("Number of requests completed: {}".\
                             format(nrequests))

            nrequests += 1

            try:
                place = gmaps.geocode(row['search_addr'])
                row['lat'] = place[0]['geometry']['location']['lat']
                row['lng'] = place[0]['geometry']['location']['lng']
                writer.writerow(row)

            except:
                logging.error("Unable to find coordinates: {}".\
                              format(row['search_addr']))
                row['lat'] = '-9'
                row['lng'] = '-9'
                writer.writerow(row)

logging.info("Completed google places API script.")
