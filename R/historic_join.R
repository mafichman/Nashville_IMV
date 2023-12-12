library(tidyverse)
library(sf)
library(mapview)


# Read in historic

historic <- st_read("~/GitHub/Nashville_IMV/data/metro/Historic/Natl_Register_Historic_Property.shp") %>%
  st_as_sf() %>%
  st_transform(4326)

# Read in venues - THIS IS THE FILEPATH IN Data_Markdown.Rmd as of 9/19/2023
nash_venue_data <- st_read("~/GitHub/Nashville_IMV/data/venue_tables/to_map/venues_v7.geojson") %>%
  st_transform(crs = 4326) %>%
  group_by(name) %>%
  slice(1) %>%
  ungroup() %>%
  mutate(x=map_dbl(geometry, ~st_centroid(.x)[[1]]),
         y=map_dbl(geometry, ~st_centroid(.x)[[2]])) %>%
  mutate(X = row_number()) %>%
  as.data.frame() %>%
  st_as_sf(coords = c("x","y"), 
           crs= 4326)

historic_venues <- st_join(nash_venue_data %>%
                  select(name, address_admin, APN, Communit_1, YearBuilt, IMV), 
                historic) %>%
  filter(is.na(HistoricDe) == FALSE) 
