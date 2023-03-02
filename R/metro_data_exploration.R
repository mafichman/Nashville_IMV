# Explore data from Metro

library(tidyverse)
library(sf)
library(foreign)
library(mapview)

# The CRS we are using is: 2274 - Tennessee State Plane (that's what Metro's data came in)

# --- Older routine ----

# take the data Metro sent (ESRI formats) and save it in faster data forms like geojson
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

# Write out Prop_LIS csv with lat/lon for CST

#Prop_LIS %>% 
#  st_transform(4326) %>% 
#  mutate(lon=map_dbl(geometry, ~st_centroid(.x)[[1]]),
#         lat=map_dbl(geometry, ~st_centroid(.x)[[2]])) %>%
#  as.data.frame() %>%
#  write.csv("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.csv")

# these are some newer, speedier data sets I wrote out

# --- Current data sets ----

# Parcels takes super long to load!

parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.geojson") %>%
  st_transform(2274)

permits <- read_sf("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.geojson") %>%
  st_transform(2274)

licenses <- read.csv("~/GitHub/Nashville_IMV/data/metro/Business_Property.csv")

Prop_LIS <- read_sf("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.geojson") %>%
  st_transform(2274)

# --- Examine some data ---

# Look up the station inn in the licenses

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

# Summarize the biz licenses by type

licenses %>%
  group_by(BUSTYPE) %>%
  tally() %>%
  View()

# Look at the relevant licenses
# Many of these are filed under things like "Musical Groups" - e.g. the Ryman

licenses %>%
  filter(BUSTYPE %in% c("Music/Performance Venue", "Event Venue", "Small Resturants-Independents",
                        "Musical Groups + Artists", "Music Artists", "Microbrewery",
                        "Full Service Resturants", "Drinking Places (Alcoholic Bev")) %>%
  View()

# Check out the properties with Land Use description as nightclubs - doing a left join - 
# We join them to businesses licenses
# This ends up being super weird!
# Sofia - can you explore why some things might not join?

Prop_LIS %>%
  as.data.frame() %>%
  filter(LUDesc %in% c("NIGHTCLUB/LOUNGE")) %>%
  left_join(., licenses, by = c("APN")) %>%
  View()

# What if we do this the other way around from the biz licenses

licenses_and_parcels <- licenses %>%
  filter(BUSTYPE %in% c("Music/Performance Venue", "Event Venue", "Small Resturants-Independents",
                        "Musical Groups + Artists", "Music Artists", "Microbrewery",
                        "Full Service Resturants", "Drinking Places (Alcoholic Bev")) %>%
  left_join(., Prop_LIS,
            by = c("APN")) %>%
  st_as_sf()

# This is a pretty good data set to help the CST researchers. Perhaps we should publish it,
# along with a dynamic, searchable table, to our Github index page.

mapView(licenses_and_parcels)
