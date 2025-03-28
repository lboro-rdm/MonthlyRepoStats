server <- function(input, output) {
  data <- reactive({
    req(input$file)
    df <- read_csv(input$file$datapath, col_types = cols()) %>% 
      mutate(
        embargo_date = as.Date(embargo_date, format = "%Y-%m-%d"),
        is_embargoed = as.numeric(is_embargoed)
      )
    return(df)
  })
  
  filtered_data <- reactive({
    req(data())
    data() %>% 
      filter(
        is_embargoed == 1 & 
          !is.na(acceptance_date) & 
          is.na(embargo_date) & 
          acceptance_date > Sys.Date() - months(3) & 
          acceptance_date <= Sys.Date() & 
          item_type %in% c("journal contribution", "conference contribution")
      )
  })
  
  output$preview <- renderTable({
    head(filtered_data())
  })
  
  output$row_count <- renderText({
    paste("Filtered Rows:", nrow(filtered_data()))
  })
  
  output$download <- downloadHandler(
    filename = "batch_download_filtered.csv",
    content = function(file) {
      write_csv(filtered_data(), file)
    }
  )
  
  output$email_preview <- renderText({
    req(input$generate_email)
    req(nrow(filtered_data()) > 0)
    
    email_text <- filtered_data() %>%
      slice(1) %>%  # Preview only the first record
      mutate(
        depositor_name = str_remove(Depositor, "\\. Deposit date: .*"),
        handle_url = paste0("https://hdl.handle.net/", handle),
        email_body = paste0(
          "Subject: REQUEST FOR REF COMPLIANT FILE VERSION FOR YOUR REPOSITORY DEPOSIT\n\n",
          "Dear ", depositor_name, ",\n\n",
          "Thank you for uploading your following paper \"", title, "\" for inclusion in the University Research Repository via LUPIN.\n",
          "The <a href='", handle_url, "'>record for your project</a> has been added to the University Research Repository at  and the file has been put under embargo until we hear back from you.\n",
          "This is because, like most publishers, ", Publisher, " do not allow their publisher copy-edited and formatted PDFs to be made freely available online elsewhere ",
          "(unless it is published as Gold Open Access with a Creative Commons licence).\n\n",
          "The version of the file that is required for deposit by the University Open Access Policy and the REF Open Access Policy (for REF Open Access compliance) ",
          "is the \"accepted version\", i.e. the authors’ final peer-reviewed manuscript as accepted for publication. It is the version after peer review related changes, ",
          "but before the post-acceptance publisher formatting and copy-editing.\n\n",
          "Please will you email us this accepted manuscript as soon as possible and we will swap the file for you – you don’t need to do anything extra in LUPIN. Thank you.\n\n",
          "Here is the diagram that HEFCE (now Research England) have provided to help clarify which version is required:\n\n",
          "<submissionworkflow.jpg>\n\n",
          "Please see the web page Promoting your research for more ways to enhance the visibility of your research.\n",
          "Details and eligibility criteria for Open Access publisher deals and discounts available to Loughborough corresponding authors can be found at:\n",
          "https://internal.lboro.ac.uk/info/research-support/publishing/open-access/oa-publisher-discounts/\n\n",
          "Best wishes,"
        )
      ) %>%
      pull(email_body)
    
    email_text
  })
}