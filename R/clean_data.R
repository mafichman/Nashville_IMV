#### Data cleaning script
### Purpose: clean Nashville music venue database to be in a format that can join easily with other datasets

## load libraries
library(tidyverse)
library(sf)
library(dplyr)


### Task 1: Re-format addresses to be consistent with administrative data


## loading manually populated venue database (as of 4/16/2023) and rename to match CFP naming conventions
pop_venue_db = read.csv("~/Github/Nashville_IMV/data/venue_tables/venues4_16.csv", header=T) %>% rename(c(name=Venue_name, url=Website_URL, address=Address_Full, address_admin=Address_Number, street=Street_Name, zip=Postcode, county=County, city=Municipality, y=Coordinates_lat, x=Coordinates_lon))

## load administrative data (very time consuming so only loading tax parcels rather than Licenses and Inspections data)
parcels = st_read("~/Github/Nashville_IMV/data/metro/Nashville_Parcel_data.shp") %>% st_transform(4269) 

## select only the two address columns from venue database to have a simpler table to work with
work_table  = select(pop_venue_db,address,address_admin) 

## select only the two address column to match and APN column from tax parcel data to have a simpler table to work with
work_join_table = select(parcels, PropAddr,APN)

## create empty "APN_Address" column to populate with venue address formated like tax parcel data addresses
work_table = work_table %>% mutate(APN_Address = address_admin)

## for any street address with less than 5 character length, substitute full address
work_table$APN_Address = ifelse(str_length(work_table$address_admin) < 5, work_table$address, work_table$address_admin)

## take off anything after comma (like city/zip info)
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=",")

## remove all periods
work_table$APN_Address = str_replace_all(work_table$APN_Address, "[.]", "")

## remove trailing new lines
work_table$APN_Address = str_replace_all(work_table$APN_Address, "[\r\n]", "")

## capitalize
work_table$APN_Address = toupper(work_table$APN_Address)

## swap nomenclature (and a few specific outliers)
swaps = c("DRIVE"="DR", "STREET"="ST", "AVENUE"="AVE", "PKwork_table$APN_Address = str_replace_all(work_table$APN_Address, swaps)"="PIKE", "CIRCLE"="CIR", "NORTH"="N", " SOUTH"=" S", "BOULEVARD"="BLVD", "PARKWAY"="PKWY", " ALLEY"=" ALY", "PLACE"="PL", "SQUARE"="SQ", " ROAD" = " RD", "BICENTENNIAL CAPITOL MALL STATE PARK- 600 JAMES ROBERTSON PIKEWY"="600 JAMES ROBERTSON PKWY", "ONE "="1 ", "FOURTH"="4TH")

## clip off more unnecessary trailing information
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" SUITE")
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" #")
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" NASHVILLE")
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" AND")
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" &")
work_table = work_table %>% separate(APN_Address,into = ("APN_Address"),sep=" STE ")

## join by address to tax parcel data - 170 out of 283 joined by address
APN_join1 = inner_join(work_table, work_join_table, by = c("APN_Address"="PropAddr"))

## view which addresses weren't joined and why
unmatched_table = left_join(work_table, work_join_table, by = c("APN_Address"="PropAddr")) %>% filter(is.na(APN)) %>% unique()
#out of first 10 unjoined addresses, 8 are because the address doesn't exist in the parcels dataset---> probabilistic match will likely not be accurate, have to go in manually

## save a local version of a full table of venues (those joined to administrative data and those unmatched) to manually match the rest
full_table = left_join(work_table, work_join_table, by = c("APN_Address"="PropAddr")) %>% unique() %>% mutate(APN_Address_Manual = "") %>% select(address,address_admin,APN_Address,APN,APN_Address_Manual)
#write.csv(full_table, file="path/filename.csv")


### Task 2: Manually add in any missing addresses that need to match administrative data, and join final address list to administrative data


## manually match the unmatched venues by going through a map of the parcel data and finding the parcel that overlaps the venue location and bringing this parcel's address into the column "APN_Address_Manual"
## put a copy of this manually matched table into "~/Github/Nashville_IMV/data/venue_tables/manual_APNs[date].csv" with date of last VENUE TABLE update

## load back in the manually matched database of venues <--> parcels that I made (last updated 6/7/2023) 
manual_match_table = read.csv("~/Github/Nashville_IMV/data/venue_tables/manual_APNs_4_16.csv", header=TRUE)

## join by address to tax parcel data - 274 out of 283 matched
APN_join2 = inner_join(manual_match_table, work_join_table, by = c("APN_Address_Manual"="PropAddr")) %>% unique()

## view which addresses weren't joined and why - should only be venues not in study area or with insufficient data
APN_nomatch = left_join(manual_match_table, work_join_table, by = c("APN_Address"="PropAddr")) %>% filter(is.na(APN)) %>% unique()

## creating useful tables

## simple table (use for all administrative and venue data joins), also rename to match CFP naming conventions
venue_admin_key_table = select(APN_join2, c(name, APN_Address_Manual, APN)) %>% rename(address_admin=APN_Address_Manual)

## venue table (all venue info and some parcel info, including coordinates)
venue_data_join = left_join(venue_admin_key_table, pop_venue_db, by="name") %>% rename(APN=APN.x) %>% select(-c(APN.y,street))

venue_coordinates = APN_join2 %>% select(c(name,geometry))
venue_coordinates$y = st_coordinates(st_centroid(venue_coordinates$geometry))[,2]
venue_coordinates$x = st_coordinates(st_centroid(venue_coordinates$geometry))[,1]
venue_coordinates = venue_coordinates %>% select(-geometry) %>% st_drop_geometry() 

venue_data_done = left_join(select(venue_data_join,-c(y,x,address,address_admin.y)),venue_coordinates) %>% rename(address_admin=address_admin.x)

## detailed table (all venue and parcel information) - lots of redundant info so commented out
#detailed_table = left_join(venue_data_done,parcels,by= c("Admin_Address"="PropAddr","APN")) %>% unique()

## if updated, save the important tables to Github

## save simple table (for joins) with date of last VENUE TABLE update
#st_write(venue_admin_key_table, "~Github/Nashville_IMV/data/venue_tables/simple_table[date].csv")

## save venue table to Github with date of last VENUE TABLE update (remember, this is just the manually updated venue list with all the information filled in)
#write.csv(venue_data_done,"~/Github/Nashville_IMV/data/venue_tables/venue_table_filled[date].csv")


### Task 3: Re-organize rest of venue attribute data

## manually download and edit venue dataset and save to Github folder

## RIGHT AFTER UPDATE load detailed venue dataset, pay mind to last update
#venue_table_detailed_load = read.csv("~/Github/Nashville_IMV/data/venue_tables/venue_table_detailed_7_3.csv", header=T)

## merge this with venue_data_done dataset to ensure all venues are counted #25 venues without APNs due to difference between dates of last updated tables
#venue_table_detailed = left_join(select(venue_table_detailed_load,-c(address,address_admin,APN,url,zip,county,city,y,x)),venue_data_done,by = "name")
#write.csv(venue_table_detailed,"~/Github/Nashville_IMV/data/venue_tables/venue_detailed_7_3.csv")

## view data dictionary to understand column names
data_dictionary_load = read.csv("~/Github/Nashville_IMV/data/venue_tables/data_dictionary_venue_detailed_7_3.csv", header=F)
data_dictionary_view = t(data_dictionary_load) %>% as.data.frame() %>% mutate(col_name=V1,col_definition=V2,survey_question=V3) %>% select(-c(V1,V2,V3))
#view(data_dictionary_view)

