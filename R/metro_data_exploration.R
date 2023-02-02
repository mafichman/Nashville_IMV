# Explore data from Metro

library(tidyverse)
library(sf)

parcels <- read_sf("~/GitHub/Nashville_IMV/data/metro/Nashville_Parcel_data.shp")

permits <- read_sf("~/GitHub/Nashville_IMV/data/metro/Permits_from2010.shp")

Prop_LIS <- read_sf("~/GitHub/Nashville_IMV/data/metro/Prop_LIS_Jan_2023/Prop_LIS_Jan_2023.shp")
