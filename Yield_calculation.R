# Load the CSV file
All_csv <- read.csv("FarmSys_pop_spam_world.csv")

# List of crops (adjust this list based on your actual column names)
crops <- c("ACOF", "BANA", "BARL", "BEAN", "CASS", "CHIC", "CNUT", "COCO", "COTT", "COWP", 
           "GROU", "LENT", "MAIZ", "OCER", "OFIB", "OILP", "OOIL", "OPUL", "ORTS", 
           "PIGE", "PLNT", "PMIL", "POTA", "RAPE", "RCOF", "REST", "RICE", "SESA", 
           "SMIL", "SORG", "SOYB", "SUGB", "SUGC", "SUNF", "SWPO", "TEAS", "TEMF", 
           "TOBA", "TROF", "VEGE", "WHEA", "YAMS")

# Loop through each crop
for (crop in crops) {
  # Calculate yield and create a new column
  All_csv[[paste0(crop, "_Y")]] <- All_csv[[paste0(crop, "_P")]] / All_csv[[paste0(crop, "_A")]]
}

All_csv[is.na(All_csv)] <- 0

# Save the updated CSV
write.csv(All_csv, "Updated_FarmSys_pop_spam_world.csv", row.names = FALSE)
