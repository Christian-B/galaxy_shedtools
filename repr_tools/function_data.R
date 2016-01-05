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
 
no_value_functions <<- c("col_names_to_data","impute_knn","na_per_column","na_per_row","transpose","transpose_impute_knn")
value_functions <<- c("two_power_relative")
all_functions <<- c(no_value_functions, value_functions)

function_options <- function(){
    funtion_help = paste("Function to apply on all the data. ",
                        paste("Currently supported funtions are (",paste(all_functions,collapse =", "),") "),
                        sep="")
    value_help = paste("If applicable the value for the function to use. ",
                        paste("Required for (",paste(value_functions,collapse =", "),") "),
                        sep="")
    new_list = list(
        make_option("--data_function", action="store", type='character', 
                    help=funtion_help),
        make_option("--compare_value", action="store", type='double', 
                    help="value_help")
    )
    return (new_list)
}

check_function  <- function(){ 
    check_variable("data_function", legal_values=all_functions)
    check_secondary_variable("data_function", value_functions,"compare_value")
}

apply_function <- function(data){
    mymessages(c("Applying function",opt$data_function, "to the data."))
    if (opt$data_function == "col_names_to_data"){
        new_data = colnames(data)
        names(new_data) = colnames(data)
    } else if (opt$data_function == "impute_knn"){
        if(exists(".Random.seed")) rm(.Random.seed)
        new_data = impute.knn(as.matrix(data))$data
    } else if (opt$data_function == "transpose_impute_knn"){
        new_data = t(data)
        if(exists(".Random.seed")) rm(.Random.seed)
        new_data = impute.knn(as.matrix(new_data))$data
        new_data = t(new_data)
    } else if (opt$data_function == "na_per_column"){
        new_data = colSums(is.na(data))
    } else if (opt$data_function == "na_per_row"){
        new_data = rowSums(is.na(data))
    } else if (opt$data_function == "transpose"){
        new_data = t(data)
    } else if (opt$data_function == "two_power_relative"){
        new_data = 2^(opt$compare_value - data)
    } else {
        myerror(c("Unexpected fuction",opt$data_function))
    }
    mysummary("data after function", new_data)
    return (new_data)
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


