library(shiny)
library(shinythemes)
library(sf)
library(dplyr)
library(leaflet)

# Load the shapefile with countries, farming systems, population, and spam data
All_shapefile <- sf::read_sf("spam_RuralPop_Country_Farmsyst.shp")

All_csv <- read.csv("FarmSys_pop_spam_world.csv")

# Define UI
ui <- fluidPage(
  titlePanel("Geospatial Data For Global Targeting of Investments in Agronomic Gains"),
  tabsetPanel(
    tabPanel("Single Selection",
             sidebarLayout(
               sidebarPanel(
                 selectInput("single_selected_country", "Select Country", 
                             choices = unique(All_csv$country)),
                 selectInput("single_selected_farming_system", "Select Farming System", 
                             choices = NULL)  # Initialize with NULL choices
               ),
               mainPanel(
                 tableOutput("data_table"),  # Display the data table here
                 # Render the map
                 leafletOutput("map"),
                 # Add a download button
                 downloadButton("downloadCSV", "Download CSV")
               )
             )
    ),
    tabPanel("Multiple Selection",
             sidebarLayout(
               sidebarPanel(
                 # Dropdown for selecting multiple countries
                 selectizeInput("multiple_selected_countries", "Select Countries", 
                                choices = unique(All_csv$country), multiple = TRUE),
                 # Dropdown for selecting multiple farming systems
                 selectizeInput("multiple_selected_farming_systems", "Select Farming Systems", 
                                choices = unique(All_csv$FARMSYS), multiple = TRUE)
               ),
               mainPanel(
                 tableOutput("data_table_multiple"),  # Display the data table here for multiple selection
                 # Render the map (you can choose to omit this for multiple selection)
                 leafletOutput("map_multiple"),
                 # Add a download button
                 downloadButton("downloadCSV_multiple", "Download CSV (Multiple Selection)")
               )
             )
    ),
    tabPanel("About",
             fluidRow(
               column(
                 width = 12,
                 h4("About this App"),
                 HTML("This app was developed by 
               <a href='https://www.cimmyt.org/'>CIMMYT</a>. 
               It provides support for ex ante evaluation of prospective agronomy interventions. 
               You can explore farming systems, population data, and harvest area information for different countries using interactive maps and tables."),
                 h5("Data Sources"),
                 HTML("This tool uses data provided by 
                <a href='https://gadm.org/'>GADM</a>, 
                <a href='http://www.fao.org/'>FAO</a>, 
                <a href='https://www.worldpop.org/'>WorldPop</a>, and 
                <a href='http://mapspam.info/'>SPAM</a>."),
                 h5("Note"),
                 p("The harvest area represented by SPAM crops is provided in hectares."),
                 h5("Code and Input Data"),
                 HTML("The code and input data used to generate this tool are available on 
             <a href='https://github.com/Madaga-L/Revised-Agripop-App'>GitHub</a>.")
               )
             )
    )
  )
)

# Define the server
server <- function(input, output, session) {
  # Update the choices for the "Select Farming System" dropdown based on the selected country
  observe({
    selected_country <- input$single_selected_country
    if (!is.null(selected_country)) {
      farming_systems <- unique(All_csv$FARMSYS[All_csv$country == selected_country])
      updateSelectInput(session, "single_selected_farming_system", choices = farming_systems)
    }
  })
  
  # Filter data based on selected country and farming system for single selection
  single_filtered_data <- reactive({
    All_csv[All_csv$country == input$single_selected_country &
              All_csv$FARMSYS == input$single_selected_farming_system, ]
  })
  
  # Filter data based on multiple selected countries and farming systems for multiple selection
  multiple_filtered_data <- reactive({
    All_csv[All_csv$country %in% input$multiple_selected_countries &
              All_csv$FARMSYS %in% input$multiple_selected_farming_systems, ]
  })
  
  # Render the filtered data table for single selection
  output$data_table <- renderTable({
    if (!is.null(input$single_selected_country) && 
        !is.null(input$single_selected_farming_system)) {
      single_filtered_data()
    }
  })
  
  # Render the filtered data table for multiple selection
  output$data_table_multiple <- renderTable({
    if (!is.null(input$multiple_selected_countries) && 
        !is.null(input$multiple_selected_farming_systems)) {
      multiple_filtered_data()
    }
  })
  
  # Render the map based on selected country and farming system for single selection
  output$map <- renderLeaflet({
    selected_country <- input$single_selected_country
    selected_farming_system <- input$single_selected_farming_system
    
    if (!is.null(selected_country) && !is.null(selected_farming_system)) {
      filtered_shape <- All_shapefile %>%
        filter(country == selected_country, FARMSYS == selected_farming_system)
      
      leaflet(data = filtered_shape) %>%
        addProviderTiles("OpenStreetMap.Mapnik") %>%
        addPolygons(stroke = TRUE,
                    fillColor = "blue", 
                    fillOpacity = 0.5, 
                    color = "white", 
                    weight = 1,
                    popup = ~glue::glue("<b>{FARMSYS}</b><br>{area_sqkm}"))
    }
  })
  
  # Render the map based on selected country and farming system for multiple selection
  output$map_multiple <- renderLeaflet({
    selected_country_multiple <- input$multiple_selected_countries
    selected_farming_system_multiple <- input$multiple_selected_farming_systems
    
    if (!is.null(selected_country_multiple) && !is.null(selected_farming_system_multiple)) {
      filtered_shape_multiple <- All_shapefile %>%
        filter(country %in% selected_country_multiple, FARMSYS %in% selected_farming_system_multiple)
      
      leaflet(data = filtered_shape_multiple) %>%
        addProviderTiles("OpenStreetMap.Mapnik") %>%
        addPolygons(stroke = TRUE,
                    fillColor = "blue", 
                    fillOpacity = 0.5, 
                    color = "white", 
                    weight = 1,
                    popup = ~glue::glue("<b>{FARMSYS}</b><br>{area_sqkm}"))
    }
  })
  
  # Define a download handler for the download button for single selection
  output$downloadCSV <- downloadHandler(
    filename = function() {
      "Filtered_data.csv"
    },
    content = function(file) {
      if (!is.null(input$single_selected_country) && 
          !is.null(input$single_selected_farming_system)) {
        write.csv(single_filtered_data(), file, row.names = FALSE)
      }
    }
  )
  
  # Define a download handler for the download button for multiple selection
  output$downloadCSV_multiple <- downloadHandler(
    filename = function() {
      "Filtered_data_multiple.csv"
    },
    content = function(file) {
      if (!is.null(input$multiple_selected_countries) && 
          !is.null(input$multiple_selected_farming_systems)) {
        write.csv(multiple_filtered_data(), file, row.names = FALSE)
      }
    }
  )
}

shinyApp(ui, server)
