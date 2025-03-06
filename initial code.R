library(httr2)
library(tidyverse)

# Step 1: Download data ---------------------------------------------------

# Upload batch download csv

library(httr2)
library(tidyverse)

# Define the URL for the JSON download
url <- "https://irus.jisc.ac.uk/r5/report/item/irus_ir_master/?sort_column=Reporting_Period_Total&sort_order=DESC&begin_date=Feb+2025&end_date=Feb+2025&items=100&report_requested=1&institution%5B0%5D=2&repository%5B0%5D=2&access_method%5B0%5D=1&access_type%5B0%5D=4&data_type%5B0%5D=12&item_type%5B0%5D=23&item_type%5B1%5D=0&item_type%5B2%5D=26&item_type%5B3%5D=1&item_type%5B4%5D=2&item_type%5B5%5D=3&item_type%5B6%5D=4&item_type%5B7%5D=5&item_type%5B8%5D=30&item_type%5B9%5D=6&item_type%5B10%5D=7&item_type%5B11%5D=28&item_type%5B12%5D=8&item_type%5B13%5D=9&item_type%5B14%5D=22&item_type%5B15%5D=10&item_type%5B16%5D=25&item_type%5B17%5D=27&item_type%5B18%5D=11&item_type%5B19%5D=12&item_type%5B20%5D=13&item_type%5B21%5D=14&item_type%5B22%5D=15&item_type%5B23%5D=16&item_type%5B24%5D=17&item_type%5B25%5D=18&item_type%5B26%5D=24&item_type%5B27%5D=29&item_type%5B28%5D=19&item_type%5B29%5D=20&item_type%5B30%5D=21&metric_type%5B0%5D=10&format=json"

# Fetch the JSON data
response <- request(url) |> 
  req_method("GET") |> 
  req_headers("Content-Type" = "application/json") |> 
  req_perform()

# Check if the request was successful
if (resp_status(response) == 200) {
  # Parse JSON response
  json_data <- resp_body_json(response)
  
  # Initialize an empty list to store the top 10 entries from each table
  top_entries_list <- list()
  
  # Loop through each table in json_data$Statistics
  for (i in seq_along(json_data$Statistics)) {
    # Extract the first 10 rows from each table and add to the list
    top_entries <- head(as_tibble(json_data$Statistics[[i]]))
    top_entries_list[[i]] <- top_entries
  }
  
  # Combine all top entries into a single tibble
  combined_top_entries <- bind_rows(top_entries_list, .id = "Table_ID")
  
  # Print the combined tibble
  print(combined_top_entries)
} else {
  message("Error fetching data: ", resp_status(response))
}


# Part1.2 get URLs from figshare ------------------------------------------

# Base URL for Figshare search API
search_url <- "https://api.figshare.com/v2/articles/search"

# Your institution ID (replace with your actual institution ID)
institution_id <- 2  # Update this to match your institution's ID

# Initialize an empty list to store search results
all_search_results <- list()

# Loop through each title in combined_top_entries$Item
for (title in combined_top_entries$Item) {
  
  # Create the request body with institution filter
  request_body <- list(
    title = title,
    page_size = 100,  # Adjust the page size as needed
    institution_id = institution_id  # Add your institution ID here
  )
  
  # Perform the POST request
  response <- request(search_url) |> 
    req_method("POST") |> 
    req_headers("Content-Type" = "application/json") |> 
    req_body_json(request_body) |> 
    req_perform()
  
  # Check if the request was successful
  if (resp_status(response) == 200) {
    # Parse JSON response
    search_results <- resp_body_json(response)
    
    # Check if there are any articles returned
    if (length(search_results) > 0 && "url_public_html" %in% names(search_results[[1]])) {
      # Extract URLs and create a tibble with title and URL
      results_df <- as_tibble(search_results) %>%
        select(url_public_html) %>%  # Select the public HTML URL
        mutate(Search_Title = title)
      
      # Append results to the list
      all_search_results[[title]] <- results_df
    }
  }
}

# Combine all search results into a single tibble
final_results <- bind_rows(all_search_results, .id = "Title")

# Print the combined results with URLs
print(final_results)

# Step 2: Clean data ------------------------------------------------------




# Step 3: Present results -------------------------------------------------


