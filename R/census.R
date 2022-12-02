# Nashville Census Data

## Load libraries

library(tidyverse)
library(tidycensus)
library(tigris)
library(sf)
library(viridis)
library(viridisLite)

## Load your census API key - the following key is Michael Fichman's
# You can go to the Census bureau and get your own

census_api_key("e79f3706b6d61249968c6ce88794f6f556e5bf3d", overwrite = TRUE)

## Load graphic palettes

plotTheme <- theme(
  plot.title =element_text(size=12),
  plot.subtitle = element_text(size=8),
  plot.caption = element_text(size = 6),
  axis.text.x = element_text(size = 10, angle = 45, hjust = 1),
  axis.text.y = element_text(size = 10),
  axis.title.y = element_text(size = 10),
  # Set the entire chart region to blank
  panel.background=element_blank(),
  plot.background=element_blank(),
  #panel.border=element_rect(colour="#F0F0F0"),
  # Format the grid
  panel.grid.major=element_line(colour="#D0D0D0",size=.75),
  axis.ticks=element_blank())

mapTheme <- theme(plot.title =element_text(size=12),
                  plot.subtitle = element_text(size=8),
                  plot.caption = element_text(size = 6),
                  axis.line=element_blank(),
                  axis.text.x=element_blank(),
                  axis.text.y=element_blank(),
                  axis.ticks=element_blank(),
                  axis.title.x=element_blank(),
                  axis.title.y=element_blank(),
                  panel.background=element_blank(),
                  panel.border=element_blank(),
                  panel.grid.major=element_line(colour = 'transparent'),
                  panel.grid.minor=element_blank(),
                  legend.direction = "vertical", 
                  legend.position = "right",
                  plot.margin = margin(1, 1, 1, 1, 'cm'),
                  legend.key.height = unit(1, "cm"), legend.key.width = unit(0.2, "cm"))

# Nashville County

acs_variable_list.2020 <- load_variables(2020, #year
                                         "acs5")

## Set up a list of variables to grab
acs_vars <- c("B01001_001E", # ACS total Pop estimate
              "B06011_001E") # Median income in past 12 months

## Grab some data for Chester County

acs2020 <- get_acs(geography = "tract",
                   year = 2020,
                   variables = acs_vars,
                   geometry = TRUE,
                   state = "TN",
                   county = "Davidson",
                   output = "wide") %>%
  select(GEOID, NAME, acs_vars) %>%
  rename(total_pop_est = B01001_001E,
         median_income_est = B06011_001E) %>%
  mutate(year = 2020)


## Let's try getting 2010 data

acs2010 <- get_acs(geography = "tract",
                   year = 2010,
                   variables = acs_vars,
                   geometry = TRUE,
                   state = "TN",
                   county = "Davidson",
                   output = "wide") %>%
  select(GEOID, NAME, acs_vars) %>%
  rename(total_pop_est = B01001_001E,
         median_income_est = B06011_001E) %>%
  mutate(year = 2010)


full_table <- rbind(acs2010, acs2020)

ggplot(full_table)+
  geom_sf(aes(fill = median_income_est),
          color = "transparent",
          alpha = 0.8)+
  scale_fill_viridis()+
  facet_wrap(~year)+
  mapTheme

ggplot(full_table)+
  geom_sf(aes(fill = total_pop_est),
          color = "transparent",
          alpha = 0.8)+
  scale_fill_viridis()+
  facet_wrap(~year)+
  mapTheme
