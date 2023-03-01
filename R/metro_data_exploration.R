# Explore data from Metro

library(tidyverse)
library(sf)
library(foreign)

# The CRS we are using is: 2274 - Tennessee State Plane (that's what Metro's data came in)

# --- Older routine ----

take the data Metro sent (ESRI formats) and save it in faster data forms like geojson
# Sofia you can use this to adjust the data in your gitignore folder to mirror mine

#parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.shp")

#parcels %>%
#  st_transform(4326) %>%
# st_write("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.geojson")

#licenses <- read.dbf("~/GitHub/Nashville_IMV/data/metro/Business_Property.dbf")

#licenses %>% write.csv("~/GitHub/Nashville_IMV/data/metro/Business_Property.csv")

#permits <- read_sf("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.shp")

#permits  %>%
#    st_transform(4326) %>%
#   st_write("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.geojson")

# I think this is the parcel data, but with 3 most recent sales
#Prop_LIS <- read_sf("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.shp")

#Prop_LIS %>%
#      st_transform(4326) %>%
#     st_write("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.geojson")

# these are some newer, speedier data sets I wrote out

# --- Current data sets ----

parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.geojson") %>%
  st_transform(2274)

permits <- read_sf("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.geojson") %>%
  st_transform(2274)

licenses <- read.csv("~/GitHub/Nashville_IMV/data/metro/Business_Property.csv")

Prop_LIS <- read_sf("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.geojson") %>%
  st_transform(2274)

# --- Examine some data ---

# Look up the station inn

Prop_LIS %>% 
  as.data.frame() %>% 
  filter(PropAddr == "402 12TH AVE S") %>% 
  View()


# Summarize the property listings by use

Prop_LIS %>%
  as.data.frame() %>%
  group_by(LUDesc) %>%
  tally() %>%
  View()

# Check out the properties licensed as nightclubs - join them to businesses licenses
# This ends up being super weird!

Prop_LIS %>%
  as.data.frame() %>%
  filter(LUDesc == "NIGHTCLUB/LOUNGE") %>%
  left_join(., licenses, by = c("APN")) %>%
  View()
