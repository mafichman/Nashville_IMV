# Chamber of commerce venues

library(tidyverse)
library(sf)
library(mapview)

# Read original shapefile and export geojson and csv
# This code is defunct - the shp has been deleted in favor of geojson

# cc_venues <- read_sf("~/GitHub/Nashville_IMV/data/chamber_venues/chamber_venues_2020.shp") %>%
#  st_transform(crs = 4326) %>%
#  mutate(lat = st_coordinates(.)[,2],
#         lon = st_coordinates(.)[,1]) %>%
#  st_write("~/GitHub/Nashville_IMV/data/chamber_venues/chamber_venues_2020.geojson") %>%
#  write.csv("~/GitHub/Nashville_IMV/data/chamber_venues/chamber_venues_2020.csv")


# Read new

cc_venues <- read_sf("~/GitHub/Nashville_IMV/data/chamber_venues/chamber_venues_2020.geojson")

# Quick map

mapView(cc_venues)
