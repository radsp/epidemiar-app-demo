
# UI parameters -------------------------------------------------------------

# Ideally country selection is filtered right away based on user permission
ctry_selection <- "Awesome country"

id_table <- read_csv("data/mdive_data_id.csv")

for(i in 1:nrow(id_table)) {
  download_civis(id_table$id[i], file = paste(id_table$name[i], ".rds", sep = ""), overwrite = TRUE)
}

epi_data <- readRDS("epi_data.rds")
env_data <- readRDS("env_data.rds")
env_ref_data <- readRDS("env_ref_data.rds")
env_info <- readRDS("env_info.rds")

# epi_data <- read_civis(sql("SELECT * FROM staging_pmihq.epidemiar_demo_epi_data")) %>%
#   mutate(obs_date = as.Date(as.character(obs_date)))
# 
# env_data <- read_civis(sql("SELECT * FROM staging_pmihq.epidemiar_demo_env_data")) %>%
#   mutate(obs_date = as.Date(as.character(obs_date)))
# 
# env_ref_data <- read_civis(sql("SELECT * FROM staging_pmihq.epidemiar_demo_env_ref_data"))
# 
# env_info <- read_civis(sql("SELECT * FROM staging_pmihq.epidemiar_demo_env_info"))

# read in woreda metadata
report_woredas <- read_csv("data/amhara_woredas.csv") %>%
  filter(report == 1)

# # read in climatology / environmental reference data
# env_ref_data <- read_csv("data/env_ref_data_2002_2018.csv", col_types = cols())
# 
# # read in environmental info file
# env_info <- read_xlsx("data/environ_info.xlsx", na = "NA")
# 
# 
# # read & process case data needed for report
# epi_data <- corral_epidemiological(report_woreda_names = report_woredas$woreda_name)
# 
# # read & process environmental data for woredas in report
# env_data <- corral_environment(report_woredas = report_woredas)
# 
# ## Optional: For slight speed increase,
# # date filtering to remove older environmental data.
# # older env data was included to demo epidemiar::env_daily_to_ref() function.
# # in make_date_yw() weekday is always end of the week, 7th day
# env_start_date <- epidemiar::make_date_yw(year = 2012, week = 1, weekday = 7)
# #filter data
# env_data <- env_data %>% filter(obs_date >= env_start_date)
# #force garbage collection to free up memory


# 1. Set up general report and epidemiological parameters ----------

#total number of weeks in report (including forecast period)
report_period <- 26

#report out in incidence 
report_value_type <-  "incidence"

#report incidence rates per 1000 people
report_inc_per <- 1000

#date type in epidemiological data
epi_date_type <- "weekISO"

#interpolate epi data?
epi_interpolate <- TRUE

#use a transformation on the epi data for modeling? ("none" if not)
#Note that this is closely tied with the model family parameter below
#   fc_model_family <- "gaussian()"
epi_transform <- "log_plus_one"

#model runs and objects
model_run <- FALSE
model_cached <- NULL


# 3. Set up forecast controls -------------------------------------

#read in model cluster information
pfm_fc_clusters <- readr::read_csv("data/falciparum_model_clusters.csv", col_types = readr::cols())

#info for parallel processing on the machine the script is running on
fc_ncores <- max(parallel::detectCores(logical=FALSE),
                 1,
                 na.rm = TRUE)


# 4. Set up early detection controls -------------------------------

#number of weeks in early detection period (last n weeks of known epidemiological data to summarize alerts)
ed_summary_period <- 4

#event detection algorithm
ed_method <- "Farrington"

#settings for Farrington event detection algorithm
pfm_ed_control <- list(
  w = 3, reweight = TRUE, weightsThreshold = 2.58,
  trend = TRUE, pThresholdTrend = 0,
  populationOffset = TRUE,
  noPeriods = 12, pastWeeksNotIncluded = 4,
  limit54=c(1,4), 
  thresholdMethod = "nbPlugin")

pv_ed_control <- list(
  w = 4, reweight = TRUE, weightsThreshold = 2.58,
  trend = TRUE, pThresholdTrend = 0,
  populationOffset = TRUE,
  noPeriods = 10, pastWeeksNotIncluded = 4,
  limit54 = c(1,4), 
  thresholdMethod = "nbPlugin")



# Shapefiles ----------------------------------------------------------


s2 <- get_shapefile(admin_level = 2)
s2_amh <- subset(s2, (country %in% "Ethiopia") & (admin1 %in% "Amhara"))

#read woreda information (metadata) file
woredas <- read_csv("data/amhara_woredas.csv") 

# Add woreda name
s2_amh$woreda <- NA
s2_amh$woreda[1:141] <- woredas$woreda_name
s2_amh$woreda[142:nrow(s2_amh)] <- paste("woreda ", row.names(s2_amh)[142:nrow(s2_amh)])

# Add zone name
s2_amh$zone <- NA
s2_amh$zone[1:141] <- woredas$zone
s2_amh$zone[142:nrow(s2_amh)] <- paste("zone ", row.names(s2_amh)[142:nrow(s2_amh)])

# WID
s2_amh$WID <- NA
s2_amh$WID[1:141] <- woredas$WID
s2_amh$WID[142:nrow(s2_amh)] <- 10000 + as.numeric(row.names(s2_amh)[142:nrow(s2_amh)])


#ED/EW summary labels for legend 
ed_overview_labels <- c("Low: No alert", 
                        "Moderate: Alert for any 1 week\n  in early detection summary period", 
                        "High: Alert for 2 or more weeks\n  in early detection summary period")
ew_overview_labels <- c("Low: No alerts",
                        "Moderate: Alert for any 1 week\n  in forecast period",
                        "High: Alerts for 2 or more weeks\n  in forecast period")


# pPlot settings ---------------------------------------------------------

overview_colors <- c("#d7301f", "#fc8d59", "#b8d6fd", "gray98")

woreda_legend <- theme(legend.title=element_blank(),
                       legend.key.width = unit(1.5, "lines"),
                       legend.key = element_blank(),
                       legend.justification = c(0, 0), 
                       legend.position = c(-.03, 1),
                       legend.direction = "horizontal",
                       legend.background = element_blank())

woreda_panel_theme <- theme(panel.border = element_blank(),
                            panel.background = element_blank(),
                            panel.grid.major.y = element_line("gray80", 0.4),
                            panel.grid.major.x = element_blank(),
                            plot.margin = unit(c(2, 1, .5, .5), "lines"))  

woreda_x_axis <- theme(axis.title.x = element_blank(),
                       axis.text.x = element_text(size = rel(0.73)),
                       axis.ticks.length =  unit(0.1, "lines"))
