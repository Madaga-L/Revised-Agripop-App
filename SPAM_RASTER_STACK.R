library(terra)

setwd("H:\\CIMMYT Shiny project\\Revised_shinyapp\\spam dataset") # physical area from SPAM SSA 2017

mylist <- list.files(pattern="._A.tif$")

mylist

r <- rast(mylist)

r

# Define the output file name
output_filename <- "spam2010V2r0_global_A.tif"

# Save the raster stack to the specified file
writeRaster(r, filename = output_filename)


