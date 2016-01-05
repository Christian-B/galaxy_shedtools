suppressPackageStartupMessages(require(optparse))
 
load_utils <- function(){
    args <- commandArgs(trailingOnly = TRUE)
    script_flag_pos = grep ("--script_dir",args)
    if (length(script_flag_pos) == 0){
        cat("--script_dir flag missing\n")
        source("brenninc_util.R")
    } else {
        if (args[script_flag_pos] == "--script_dir") {
            script_dir = args[script_flag_pos+1]
        } else {
            script_dir = substring(args[script_flag_pos],14)
        }
        source(paste0(c(script_dir,"brenninc_utils.R"), collapse = "/"))
    }
}
 
extract_column_options <- function(){
    new_list = list(
        make_option("--extract_column_name", action="store", type='character', 
                    help="Name of column which holds the data to be extracted"),
        make_option("--extract_column", action="store", type='integer', 
                    help="Number of column which holds the data to be extracted")
    )
    return (new_list)
}

check_extract_column  <- function(){ 
    check_variable("extract_column_name", optional=TRUE)
    check_variable("extract_column", optional=TRUE, minimum=1)
}


extract_column <- function(data){
    extract_column <- check_column(data, "extract_column_name", "extract_column")
    data = data[,extract_column]
    mysummary("Extracted column", data)
    return (data)
}
  


#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (extract_column_options())

    check_extract_column()

    data <- read_the_data(description="Input data")

    data <- extract_column(data)

    write_the_data (data, "Extracted Column")

} 


