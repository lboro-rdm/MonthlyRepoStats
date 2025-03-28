library(shiny)
library(tidyverse)

options(shiny.maxRequestSize = 300 * 1024^2)

ui <- fluidPage(
  titlePanel("CSV Filter App"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV", accept = ".csv"),
      downloadButton("download", "Download Filtered CSV"),
      actionButton("generate_email", "Generate Email Preview")
    ),
    mainPanel(
      verbatimTextOutput("email_preview")
    )
  )
)