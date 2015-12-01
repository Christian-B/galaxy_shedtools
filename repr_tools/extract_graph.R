suppressPackageStartupMessages(require(made4))
suppressPackageStartupMessages(require(impute))
suppressPackageStartupMessages(require(repr))
suppressPackageStartupMessages(require(optparse))

load_scripts <- function(){
    args <- commandArgs(trailingOnly = TRUE)
    script_flag_pos = grep ("--script_dir",args)
    if (length(script_flag_pos) == 0){
        cat("--script_dir flag missing\n")
        source("brenninc_util.R")
        source("filter_data.R")
        source("extract_data.R")
        source("do_graph.R")
    } else {
        if (args[script_flag_pos] == "--script_dir") {
            script_dir = args[script_flag_pos+1]
        } else {
            script_dir = substring(args[script_flag_pos],14)
        }
        source(paste0(c(script_dir,"brenninc_utils.R"), collapse = "/"))
        source(paste0(c(script_dir,"filter_data.R"), collapse = "/"))
        source(paste0(c(script_dir,"extract_data.R"), collapse = "/"))
        source(paste0(c(script_dir,"do_graph.R"), collapse = "/"))
    }
}
 

#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    print ("here 1")
    load_scripts()
    print ("here 2")

    local_options <- c(filter_options(), extract_options(), graph_options())
    print(local_options)
    init_utils (local_options)

    check_filter()
    check_extract()
    check_graph()

    data <- read_the_data(description="Input Data")

    data = do_filter(data)

    data <- extract_the_values(data)

    write_the_data (data, "Extracted Data")

    graph_data(data)

}
