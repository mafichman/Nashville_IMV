#### Data cleaning script
### Purpose: clean Nashville music venue database to be in a format that can join easily with other datasets

## load libraries
library(tidyverse)
library(sf)
library(dplyr)


### Task 1: Re-format addresses to be consistent with administrative data

## loading manually populated venue database (as of 4/16/2023) and rename to match CFP naming conventions
#renames_short = c("name"="Venue_name", "url"="Website_URL", "address"="Address_Full", "address_admin"="Address_Number", "street"="Street_Name", "zip"="Postcode", "county"="County", "city"="Municipality", "y"="Coordinates_lat", "x"="Coordinates_lon")
renames_long = c("name"="V1", "liaison"="V2", "ownership_structure"="V3", "capacity"="V4", "independent_booking"="V5", "events_per_month"="V6", "years_operating"="V7", "funding_source"="V8", "interdisciplinarity"="V9", "event_promotion"="V10", "purpose"="V11", "community_focus"="V12", "creativity"="V13", "experimentation"="V14", "threats_neighbors"="V15", "threats_cost"="V16", "threats_licensing"="V17", "description"="V18", "contact_name"="V19", "contact_email"="V20", "contact_telephone"="V21", "url"="V22", "address"="V23", "address_admin"="V24", "street"="V25", "zip"="V26", "county"="V27", "city"="V28", "APN"="V29", "y"="V30", "x"="V31", "genre"="V32", "venueType_club"="V33", "venueType_disco"="V34", "venueType_openAir"="V35", "venueType_concertHall"="V36", "venueType_theater"="V37", "venueType_cinema"="V38", "venueType_musicBar"="V39", "venueType_gallery"="V40", "venueType_restaurant"="V41", "venueType_warehouse"="V42", "venueType_arena"="V43", "venueType_shop"="V44", "venueType_studio"="V45")
#renames_long2 = c("Venue name"="name", "Liaison responsible to fill out sheet?"="liaison", "Ownership Structure: 1. Yes 2. No 3. Information unavailable"="ownership_structure", "Capacity (Numeric Input)"="capacity", "Independent Booking: 1. Always 2. Sometimes 3. Never 4. Information unavailable"="independent_booking", "Events per Month: 1. 1-4 2. 5-10 3. 11-20 4. 20+"="events_per_month", "Years of Operation: 1. 0-3 2. 3-10 3. 11-20 4. 20+"="years_operating", "Artist payment based mostly on: 1. Ticket sales 2. Bar/food sales (e.g. flat fee) 3. Tips 4. Mixed/all of the above"="funding_source", "Interdisciplinarity: 1.Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="interdisciplinarity", "Promoting events: 1. Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="event_promotion", "Main purpose: 1. Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="purpose", "Community Focus: 1. Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="community_focus", "Creative Output: 1. Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="creativity", "Experimentation: 1. Not At All Likely 2. Not too likely 3. Somewhat likely 4. Very Likely"="experimentation", "Threats: Neighbors-related"="threats_neighbors", "Threats: Costs / rents-related"="threats_cost", "Threats: Licensing-related"="threats_licensing", "Venue short description"="description", "Contact person"="contact_name", "Email address"="contact_email", "Telephone number"="contact_telephone", "Website URL"="url", "Address Full"="address", "Address Number"="address_admin", "Street Name"="street", "Postcode"="zip", "County"="county", "Municipality"="city", "APN"="APN", "Coordinates (latitude)"="y", "Coordinates (longitude)"="x", "Genre: "="genre", "Club"="venueType_club", "Disco (mainstream)"="venueType_disco", "Outdoor stage (open air)"="venueType_openAir", "Concert hall / livehouse"="venueType_concertHall", "Theatre"="venueType_theater", "Cinema"="venueType_cinema", "Music Bar"="venueType_musicBar", "Gallery / museum space"="venueType_gallery", "Restaurant / cafe"="venueType_restaurant", "Rental venue / warehouse"="venueType_warehouse", "Arena / stadium"="venueType_arena", "Retail store / Shop"="venueType_shop", "Production studio / Co-working space"="venueType_studio")
pop_venue_db = read.csv("~/Github/Nashville_IMV/data/venue_tables/venues_[date].csv", header=F) %>% rename(renames_long)
pop_venue_db = pop_venue_db[-c(1:4),]

## load administrative data (very time consuming so only loading tax parcels rather than Licenses and Inspections data)
parcels = st_read("~/Github/Nashville_IMV/data/metro/Nashville_Parcel_data.shp") %>% st_transform(4269) 

## select only the two address columns from venue database to have a simpler table to work with
work_table  = select(pop_venue_db,name,address,address_admin) 

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
full_table = left_join(work_table, work_join_table, by = c("APN_Address"="PropAddr")) %>% unique() %>% mutate(APN_Address_Manual = "") %>% select(name,address,address_admin,APN_Address,APN,APN_Address_Manual)
#write.csv(full_table, file="~/Github/Nashville_IMV/data/venue_tables/manual_APNs_[date].csv")


### Task 2: Manually add in any missing addresses that need to match administrative data, and join final address list to administrative data


## manually match the unmatched venues by going through a map of the parcel data and finding the parcel that overlaps the venue location and bringing this parcel's address into the column "APN_Address_Manual"
## put a copy of this manually matched table into "~/Github/Nashville_IMV/data/venue_tables/manual_APNs[date].csv" with date of last VENUE TABLE update

## load back in the manually matched database of venues <--> parcels that I made (last updated 6/7/2023) 
manual_match_table = read.csv("~/Github/Nashville_IMV/data/venue_tables/manual_APNs_[date].csv", header=TRUE)

## join by address to tax parcel data - 274 out of 283 matched
APN_join2 = inner_join(manual_match_table, work_join_table, by = c("APN_Address_Manual"="PropAddr")) %>% unique() %>% select(-APN.x) %>% rename(APN = APN.y)

## view which addresses weren't joined and why - should only be venues not in study area or with insufficient data
APN_nomatch = left_join(manual_match_table, work_join_table, by = c("APN_Address"="PropAddr")) %>% filter(is.na("APN")) %>% unique()

## creating useful tables

## simple table (use for all administrative and venue data joins), also rename to match CFP naming conventions
venue_admin_key_table = select(APN_join2, c(name, APN_Address_Manual, APN)) %>% rename(address_admin=APN_Address_Manual)

## join correct coordinate info
venue_data_join = left_join(venue_admin_key_table, pop_venue_db, by="name") %>% rename(APN=APN.x) %>% select(-c(APN.y,street))

venue_coordinates = APN_join2 %>% select(c(name,geometry))
venue_coordinates$y = st_coordinates(st_centroid(venue_coordinates$geometry))[,2]
venue_coordinates$x = st_coordinates(st_centroid(venue_coordinates$geometry))[,1]
venue_coordinates = venue_coordinates %>% select(-geometry) %>% st_drop_geometry() 

venue_data = left_join(select(venue_data_join,-c(y,x,address,address_admin.y)),venue_coordinates) %>% rename(address_admin=address_admin.x)

## reformat multiple-choice survey answers to numeric so they can be aggregated (all metadata is saved in the data dictionary)
variables_to_ordinal = c("ownership_structure","independent_booking","events_per_month","years_operating","funding_source","interdisciplinarity","event_promotion","purpose","community_focus","creativity","experimentation")
to_ordinal=function(vector){
  v = case_when(substr(x,1,1)=="1"~1,substr(x,1,1)=="2"~2,substr(x,1,1)=="3"~3,substr(x,1,1)=="4"~4)
  return(v)
}
venue_data$ownership_structure_ord = to_ordinal(venue_data$ownership_structure)
venue_data$independent_booking_ord = to_ordinal(venue_data$independent_booking)
venue_data$events_per_month_ord = to_ordinal(venue_data$events_per_month)
venue_data$years_operating_ord = to_ordinal(venue_data$years_operating)
venue_data$funding_source_ord = to_ordinal(venue_data$funding_source)
venue_data$interdisciplinarity_ord = to_ordinal(venue_data$interdisciplinarity)
venue_data$event_promotion_ord = to_ordinal(venue_data$event_promotion)
venue_data$purpose = to_ordinal(venue_data$purpose_ord)
venue_data$community_focus_ord = to_ordinal(venue_data$community_focus)
venue_data$creativity_ord = to_ordinal(venue_data$creativity)
venue_data$experimentation_ord = to_ordinal(venue_data$experimentation)

venue_data_done = venue_data

## detailed table (all venue and parcel information) - lots of redundant info so commented out
#detailed_table = left_join(venue_data_done,parcels,by= c("Admin_Address"="PropAddr","APN")) %>% unique()

## if updated, save the important tables to Github

## save simple table (for joins) with date of last VENUE TABLE update
#write.csv(venue_admin_key_table,"~/Github/Nashville_IMV/data/venue_tables/simple_table_[date].csv")

## save venue table to Github with date of last VENUE TABLE update (remember, this is just the manually updated venue list with all the information filled in)
#write.csv(venue_data_done,"~/Github/Nashville_IMV/data/venue_tables/venue_table_filled_[date].csv")


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

