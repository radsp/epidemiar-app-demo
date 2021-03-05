get_shapefile <- function(admin_level, file_id) {
  # stop if no input aruments are provided
  if (missing(admin_level) & missing(file_id) )
    stop("Please provide either an admin aggregation level (admin_level) or a file ID (file_id).")
  if (!missing(admin_level) & !missing(file_id) )
    stop("Please provide only one input arguement (admin_level) or (file_id).")
  
  # get file id or file name based on user input
  if (!missing(admin_level) & missing(file_id)) {
    file_name <- paste0("combo_admin",admin_level,"_simple_aligned")
    # obtain a list of the files in civis PMI shapefile project using the civis function
    objects <- projects_get(110044)
    # flatten nested list into data frame for searching
    obj_files_list <- objects$files
    obj_files_df <- as.data.frame(matrix(unlist(obj_files_list), ncol=5,byrow = TRUE),stringsAsFactors = FALSE)[,c(1,4)]
    colnames(obj_files_df) <- c("file_id","file_name")
    # get file id
    idx <- which(obj_files_df$file_name ==file_name)
    file_id <- as.numeric(obj_files_df$file_id[idx])
  } else if (missing(admin_level) & !missing(file_id)) {
    file_name<-files_get(file_id)$name 
  } 
  # create temp files and directories
  temp_dir <- tempdir()
  temp_file <- tempfile()
  temp_dir_sf_name <- paste0(temp_dir,"/",file_name,"/")  
  
  # extract country name from report title
  download_civis(file_id, file = temp_file, overwrite = TRUE) # download file
  unzip(temp_file, exdir = temp_dir)
  return(sf::st_read(dsn = temp_dir_sf_name, layer = file_name)) # load into R
  
}
