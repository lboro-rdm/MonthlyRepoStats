library(tidyverse)

# Read the CSV file
batch_download <- read_csv("batch_download.csv", col_types = cols())

# Convert embargo_date to Date format
batch_download <- batch_download %>% 
  mutate(embargo_date = as.Date(embargo_date, format = "%Y-%m-%d"))

# Ensure is_embargoed is treated as numeric
batch_download <- batch_download %>% 
  mutate(is_embargoed = as.numeric(is_embargoed))

# Filter rows that meet the criteria
filtered_batch <- batch_download %>% 
  filter(is_embargoed == 1 & !is.na(acceptance_date) & !is.na(embargo_date) & embargo_date > Sys.Date())

# Save the filtered file
write_csv(filtered_batch, "batch_download_filtered.csv")

# Print summary
print(nrow(filtered_batch))
