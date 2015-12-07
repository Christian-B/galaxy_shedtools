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
 
function_options <- function(){
    new_list = list(
        make_option("--data_function", action="store", type='character', 
                    help="Function to apply on all the data. Currently supported funtions are na_per_column, na_per_row")
    )
    return (new_list)
}

check_function  <- function(){ 
    check_variable("data_function", legal_values=c("impute_knn","na_per_column","na_per_row","transpose"))
}


apply_function <- function(data){
    mymessages(c("Applying function",opt$data_function, "to the data."))
    if (opt$data_function == "impute_knn"){
        if(exists(".Random.seed")) rm(.Random.seed)
        new_data = impute.knn(as.matrix(data))$data
    } else if (opt$data_function == "na_per_column"){
        new_data = colSums(is.na(data))
    } else if (opt$data_function == "na_per_row"){
        new_data = rowSums(is.na(data))
    } else if (opt$data_function == "transpose"){
        new_data = t(data)
    } else {
        myerror(c("Unexpected fuction",opt$data_function))
    }
    mysummary("data after function", new_data)
    return (new_data)
}
  
set_input <- function(){
    opt$input_file <<- "test-data/khan_expr.tsv"
}

#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (function_options())

    check_function()
 
    data <- read_the_data(description="Input data")

    data <- apply_function(data)

    write_the_data (data, paste0("data after ", opt$data_functio, collapse = " "))

} 


