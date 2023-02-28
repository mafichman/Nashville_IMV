# Explore data from Metro

library(tidyverse)
library(sf)
library(foreign)

# The CRS we are using is: 2274 - Tennessee State Plane (that's what Metro's data came in)

# Older routine - take the data Metro sent (ESRI formats) and save it in faster data forms like geojson
# Sofia you can use this to adjust the data in your gitignore folder

#parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.shp")

#parcels %>%
#  st_transform(4326) %>%
#st_write("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.geojson")

#licenses <- read.dbf("~/GitHub/Nashville_IMV/data/metro/Business_Property.dbf")

#licenses %>% write.csv("~/GitHub/Nashville_IMV/data/metro/Business_Property.csv")

permits <- read_sf("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.shp")

Prop_LIS <- read_sf("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.shp")

# these are some newer, speedier data sets I wrote out

parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.geojson") %>%
  st_transform(2274)

licenses <- read.csv("~/GitHub/Nashville_IMV/data/metro/Business_Property.csv")

