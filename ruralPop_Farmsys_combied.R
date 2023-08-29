setwd("H:\\CIMMYT Shiny project\\Revised_shinyapp")

library(terra)
library(sf)
library(dplyr)

# Load the shapefile with countries and farming systems
Data_All_countries <- terra::vect("country_farming_system.shp")

#read AFr rural population dataset
pop <- rast("ruralpop_2020_1km_Aggregated.tif")

# Extract population data by farming system
population_by_farming_system <- terra::extract(pop, Data_All_countries)

class(population_by_farming_system)

head(population_by_farming_system)

tail(population_by_farming_system)


# Calculate total population by farming system within each region
population_summary <- population_by_farming_system %>%
  group_by(ID) %>%
  summarize(RuralPop = sum(ruralpop_2020_1km_Aggregated, na.rm = TRUE))


# Merge the population summary with Data_African_countries based on the common "ID" column
(
  Pop_country_sf <- 
    #--- back to sf ---#
    st_as_sf(Data_All_countries) %>% 
    #--- define ID ---#
    mutate(ID := seq_len(nrow(.))) %>% 
    #--- merge by ID ---#
    left_join(., population_summary, by = "ID")
)

# Save the merged dataset with population information
st_write(Pop_country_sf, "Rural_Pop_by_Country_Farmsys.shp")

