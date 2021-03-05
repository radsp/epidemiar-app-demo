ui <- fluidPage(
  
  title = "EPIDEMIAR Demo",
  theme = shinytheme("flatly"),
  useShinyjs(),
  
  tags$head(tags$style(HTML('#Sidebar {width: 1400px;}'))),
  
  navbarPage(HTML("EPIDEMIAR"),
    tabPanel("Tool",
      div(id = "Sidebar", 
          sidebarPanel(
            fluidRow(style = "margin-right:-30px;",
              column(width = 10, HTML("<h3>Model Inputs and Parameters</h3>")),
              column(width = 2, style = "margin-top: 15px;", 
                     actionBttn("hide_sidebar", label = NULL, style = "material-circle", 
                                icon = icon("arrow-left"), 
                                size = "sm", color = "default"),
                     bsTooltip("hide_sidebar", title = "Hide panel", 
                                placement = "top", trigger = "hover"))
            ),
            br(),
            hr(style = "border-top: 1px solid #9aa5a6;"),
            HTML("<h4>Input Data</h4>"),
            br(),
            fluidRow(
              column(6, selectInput(inputId = "country", label = "Country", choices = ctry_selection)),
              column(6, selectInput(inputId = "spatial_aggr", label = "Select administrative level", 
                                    choices = c("Level 1" = "admin1", "Level 2" = "admin2"),
                                    selected = "admin2"))
            ),
            selectInput(inputId = "date_range", label = "Select time period", choices = c("TBD1", "TBD2")),
            selectInput(inputId = "epi_indi", label = "Select indicator to be modeled", 
                        choices = c("Malaria confirmed cases" = "confirmed_cases")),
            pickerInput(inputId = "env_indi", label = "Select environmental covariates",
                        choices = c("Rainfall" = "totprec", 
                                    "Land surface temperature (day)" = "lst_day", 
                                    "Land surface temperature (night)" = "lst_night",
                                    "Normalized difference vegeration index (NDVI)" = "ndvi", 
                                    "Normalized difference water index (NDWI)" = "ndwi6"),
                        selected = c("totprec", "lst_day", "ndwi6"), 
                        options = list('actions-box' = TRUE),
                        multiple = TRUE),
            checkboxInput(inputId = "env_anomalies", label = "Include environmental anomaly", value = TRUE),
            numericInput(inputId = "env_lag_length", label = "Maximum environmental lag (in months)",
                        value = "6", min = 0, max = 13, step = 1),
            br(),
            hr(style = "border-top: 1px solid #9aa5a6;"),
            HTML("<h4>Model parameters</h4>"),
            br(),
            selectInput(inputId = "fc_model_family", label = "Error distribution family", 
                        choices = c("Gaussian" = "gaussian()"), selected = "gaussian()"),
            selectInput(inputId = "fc_splines", label = "Spline function used to model long-term trend and lagged environmental variable",
                        choices = c("Thin plate" = "tp"), selected = "tp"),
            checkboxInput(inputId = "fc_cyclicals", label = "Include seasonal cyclical in the model", value = TRUE),
            checkboxInput(inputId = "env_anomalies", label = "Include environmental anomaly", value = TRUE),
            numericInput(inputId = "fc_future_period", label = "Forecast span (in months)", 
                         value = 2, min = 2, max = 2),
            br(),
            hr(style = "border-top: 1px solid #9aa5a6;"),
            br(),
            actionButton(inputId = "run_model", label = "Run model")
          )
      ), 
      mainPanel(
        fluidRow(style = "margin-left:-40px;",
          hidden(
            div(id = "side_expand", 
              column(width = 1,# style = "background-color:#4d3a7d;",
                     # wellPanel(
                       actionBttn("showSidebar", label = NULL, style = "material-circle",
                                  icon = icon("arrow-right"), size = "sm", color = "default")) #)
              
          )),
          
          column(width = 10, offset = 1, 
                 
                 fluidRow(uiOutput("result_header")),
                 
                 fluidRow(column(10, leafletOutput("out_map"))),
                 
                 hr(),
                 
                 # fluidRow( HTML("<h4>Time series</h4>") ),
                 
                 fluidRow(uiOutput("timeseries_txt")),
                 
                 fluidRow(uiOutput("woreda_select_input")),
                 
                 
                 fluidRow(plotOutput("ts_output"))
          
          )
          
          
          # column(width = 10, offset = 1, plotOutput("myplot"))
        )
          
          
        
      ) # end "TOOL" main panel
    ), # end "TOOL" tab panel
    tabPanel("Documentation",
      "Put methods, data etc here"
    )
  )
)