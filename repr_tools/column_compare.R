suppressPackageStartupMessages(require(made4))
suppressPackageStartupMessages(require(impute))
suppressPackageStartupMessages(require(repr))
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
 
column_compare_options <- function(){
    new_options = list(
        make_option("--compare_column_name", action="store", type='character', 
                    help="Name of column to compare with all other columns"),
        make_option("--compare_column_number", action="store", type='integer', 
                    help="Number of column to compare with all other columns"),
        make_option("--compare_method", action="store", type='character', default = "delta_ct",
                    help="Function to do the compare. Currently supported method is delta_ct")
    )
    return (new_options)
}

check_column_compare  <- function(){ 
    check_variable("compare_column_name", optional=TRUE)
    check_variable("compare_column_number", optional=TRUE, minimum=1)
    check_variable("compare_method", legal_values=c("delta_ct"))
}

do_check_column  <- function(data){ 
    compare_column <- check_column(data, "compare_column_name", "compare_column_number")

    if (opt$compare_method == "delta_ct"){
        data = data[,compare_column] - data
        return (2^data)
    } else {
        myerror(c("Unexpected compare_method",opt$compare_method))
    }
}

#Main

if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (column_compare_options())

    check_column_compare ()

    data <- read_the_data(description="Input data")

    data = do_check_column(data)

    write_the_data (data, paste0(opt$compare_method, "data", collapse = " "))

}



