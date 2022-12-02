# 311 data

library(tidyverse)
library(sf)
library(RSocrata)

# Get 311 for a week in Jan 2022

dat <- read.socrata("https://data.nashville.gov/resource/7qhx-rexh.json?$where=date_time_opened%20between%20%272022-01-01T03:30:00.000%27%20and%20%272022-01-10T03:30:00.000%27")

# What are the categories?

dat %>%
  group_by(case_request) %>%
  tally()

dat %>%
  filter(case_request %in% c("Public Safety", "Permits", "Property Violations")) %>%
  group_by(case_subrequest) %>%
  tally() %>%
  View()
