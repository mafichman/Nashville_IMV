# Nashville_IMV
Analysis Hub for Praxis / VibeLab study of Metro Nashville's Independent Music Venues

This repo contains analysis of municipal data on licensing, zoning, land use, business registrations, and real estate.

Orientation of the repo
 - Data folder: all the data
  - metro: all non-venue data: business licenses, fire department dataset, tax parcels, L&I dataset
  - venue_tables: all venue data ([date] = date of last download from google drive)
    - venues[date]: venue table downloaded from google drive
    - manual_APNs[date]: venue table with addresses reformated to match admin. address format, AND tedious matching done on the actual CSV referencing map of tax parcels and searching addresses
    - simple_table[date]: just venue name, address, and APN
    - venue_table_filled[date]: more variables added to simple table
    - venue_table_detailed[date] : even more variables added
    - data_dictionary_venue_detailed[date]: CFP-style feature names matched to original feature names
  - chamber venues: ignore, we replaced in code with manually collected venue dataset
  
- R folder: scripts
  - clean_data.R: run when data gets re-downloaded from google drive
  
  
Process to update data:
- redownload to google drive and save in ~Github/Nashville_IMV/data/venue_tables/venues[date].csv
- update name of venue table to load into clean_data.R and uncomment script that writes venues to csv after address matching
- open manual_APN[date] table and open arcmap and insert the parcel file. navigate to the addresses with missing matches, click on the parcel over that address, copy the parcel dataset address and paste into csv. reference last iteration of manual_APN csv
- uncomment all other code in clean_data.R that writes tables into Github (make sure to update the data)
- re-run rest of clean_data.R code
- comment code that writes data and save clean_data.R
- update all file names in "load venue datasets" chunk in markdown

Markdown 
- loads in data
- joins venue data to council districts
- joins census, parcel, fire department, and business data into venue dataset
- (coming soon) analysis
