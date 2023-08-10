#### Data cleaning script
### Purpose: clean Nashville music venue database to be in a format that can join easily with other datasets

## load libraries
library(tidyverse)
library(sf)
library(dplyr)


### Task 1: Re-format addresses to be consistent with administrative data

## loading manually populated venue database (as of 4/16/2023) and rename to match CFP naming conventions
renames_long = c("name"="V1", "liaison"="V2", "ownership_structure"="V3", "capacity"="V4", "independent_booking"="V5", "events_per_month"="V6", "years_operating"="V7", "funding_source"="V8", "interdisciplinarity"="V9", "event_promotion"="V10", "purpose"="V11", "community_focus"="V12", "creativity"="V13", "experimentation"="V14", "threats_neighbors"="V15", "threats_cost"="V16", "threats_licensing"="V17", "description"="V18", "contact_name"="V19", "contact_email"="V20", "contact_telephone"="V21", "url"="V22", "address"="V23", "address_admin"="V24", "street"="V25", "zip"="V26", "county"="V27", "city"="V28", "APN"="V29", "y"="V30", "x"="V31", "genre"="V32", "venueType_club"="V33", "venueType_disco"="V34", "venueType_openAir"="V35", "venueType_concertHall"="V36", "venueType_theater"="V37", "venueType_cinema"="V38", "venueType_musicBar"="V39", "venueType_gallery"="V40", "venueType_restaurant"="V41", "venueType_warehouse"="V42", "venueType_arena"="V43", "venueType_shop"="V44", "venueType_studio"="V45")
pop_venue_db = read.csv("~/Github/Nashville_IMV/data/venue_tables/New_8_9/venue_8_9.csv", header=F) %>% rename(renames_long)
pop_venue_db = pop_venue_db[-c(1:4),]

## load administrative data (very time consuming so only loading tax parcels rather than Licenses and Inspections data)
parcels = st_read("~/Github/Nashville_IMV/data/metro/Nashville_Parcel_data.shp") %>% st_transform(4269) 

## select only the two address column to match and APN column from tax parcel data to have a simpler table to work with
work_join_table = select(parcels, PropAddr,APN)


## simple table (use for all administrative and venue data joins), also rename to match CFP naming conventions
venue_admin_key_table = read.csv("~/Github/Nashville_IMV/data/venue_tables/simple_table_4_16.csv")

## join by address to tax parcel data
APN_join2 = inner_join(venue_admin_key_table, work_join_table, by = c("address_admin"="PropAddr")) %>% unique() %>% select(-APN.x) %>% rename(APN = APN.y)

## check for any that didn't match
#APN_nomatch = left_join( work_join_table, venue_admin_key_table, by = c("PropAddr"="address_admin")) %>% filter(is.na("APN")) %>% unique()

## join correct coordinate info
venue_data_join = left_join(venue_admin_key_table, pop_venue_db, by="name") %>% rename(APN=APN.x) %>% select(-c(APN.y,street))

venue_coordinates = APN_join2 %>% select(c(name,geometry))
venue_coordinates$y = st_coordinates(st_centroid(venue_coordinates$geometry))[,2]
venue_coordinates$x = st_coordinates(st_centroid(venue_coordinates$geometry))[,1]
venue_coordinates = venue_coordinates %>% select(-geometry) %>% st_drop_geometry() 

venue_data = left_join(select(venue_data_join,-c(y,x,address,address_admin.y)),venue_coordinates) %>% rename(address_admin=address_admin.x)

## reformat multiple-choice survey answers to numeric so they can be aggregated (all metadata is saved in the data dictionary)
#variables_to_ordinal = c("ownership_structure","independent_booking","events_per_month","years_operating","funding_source","interdisciplinarity","event_promotion","purpose","community_focus","creativity","experimentation")
to_ordinal = function(vector){
  v = case_when(substr(vector,1,1)=="1"~1,
                substr(vector,1,1)=="2"~2,
                substr(vector,1,1)=="3"~3,
                substr(vector,1,1)=="4"~4,
                .default = NULL
                )
  return(v)
}
venue_data$interdisciplinarity_ord = to_ordinal(venue_data$interdisciplinarity)
venue_data$event_promotion_ord = to_ordinal(venue_data$event_promotion)
venue_data$community_focus_ord = to_ordinal(venue_data$community_focus)
venue_data$creativity_ord = to_ordinal(venue_data$creativity)
venue_data$experimentation_ord = to_ordinal(venue_data$experimentation)

#to_binary = function(vector){
  v = case_when(substr(vector,1,1)=="1"~1,
                substr(vector,1,1)=="2"~1,
                substr(vector,1,1)=="3"~0,
                substr(vector,1,1)=="4"~0,
                .default = 0
  )
  return(v)
}

to_binary = function(vector) {
  v = case_when(
    substr(vector, 1, 1) == "1" ~ 1,
    TRUE ~ 0
  )
  return(v)
}


venue_data$ownership_structure_ord = to_binary(venue_data$ownership_structure)
venue_data$independent_booking_ord = to_binary(venue_data$independent_booking)


## save
write.csv(venue_data,"~/Github/Nashville_IMV/data/venue_tables/New_8_9/venue_8_9_populated.csv")

