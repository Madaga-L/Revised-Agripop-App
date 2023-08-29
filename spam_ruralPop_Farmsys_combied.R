setwd("H:\\CIMMYT Shiny project\\Revised_shinyapp")

library(terra)
library(sf)
library(dplyr)

# Load the shapefile with countries and farming systems
Data_All_countries <- terra::vect("Rural_Pop_Country_Farmsys.shp")

#read AFr rural population dataset
spam <- rast("spam2010V2r0_global_A_prj.tif")

# Extract population data by farming system
spam_by_farming_system <- terra::extract(spam, Data_All_countries, fun = sum, na.rm = TRUE)

class(spam_by_farming_system)

head(spam_by_farming_system)

tail(spam_by_farming_system)


# Merge the population summary with Data_African_countries based on the common "ID" column
(
  Pop_country_sf <- 
    #--- back to sf ---#
    st_as_sf(Data_All_countries) %>% 
    #--- define ID ---#
    mutate(ID := seq_len(nrow(.))) %>% 
    #--- merge by ID ---#
    left_join(., spam_by_farming_system, by = "ID")
)

# Save the merged dataset with population information
st_write(Pop_country_sf, "Rural_Pop_by_Country_Farmsys.shp")

