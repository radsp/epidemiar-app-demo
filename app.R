
# Libraries --------------------------------------------------------------------

if (!require("pacman")) install.packages("pacman")

pacman::p_load(dplyr, knitr, lubridate, readr, readxl, tidyr, tools, forcats, ggplot2,
               shiny, shinyjs, shinythemes, shinyWidgets, shinyBS, leaflet)

devtools::install_github("EcoGRAPH/clusterapply")

remotes::install_github("ecograph/epidemiar@v3.1.1", build = TRUE, 
                        build_opts = c("--no-resave-data", "--no-manual"))

library(clusterapply)
library(epidemiar)
library(civis)

# Source ------------------------------------------------------------------------

source("util.R")
source("data_corrals.R")
source("global.R")
source("app_ui.R")
source("app_server.R")


# App ----------------------------------------------------------------------------

shinyApp(ui = ui, server = server)