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
 
filter_options <- function(){
    help_filter = paste("One or more filter to apply to the data. ",
                        "Seperate filters can be divided by commas. ",
                        symbols_option,
                       "No other filter_** parameter needs to be provided.", sep="")
    new_options = list(
        make_option("--filter", action="store", type='character', default=NULL,
                    help=help_filter),   
        make_option("--filter_column_name", action="store", type='character', default=NULL,
                    help="Name of the column to filter on."),
        make_option("--filter_column_number", action="store", type='integer', default=NULL,
                    help="Number the column to filter on.")
    )
    return (c(global_filter_options(), new_options))
}

check_filter  <- function(){ 
    found_name <- check_one_of(c("filter_column_name","filter_column_number"))
    if (is.na(found_name)){
        opt$filter <<- remove_symbols(opt$filter)
        check_variable("filter")
        check_not_global_filter("neither filter_column_name nor filter_column_number provided")
    } else {
        check_global_filter()
    }
}

do_filter  <- function(data){ 
    filter_column_name <- check_column(data, "filter_column_name", "filter_column_number", optional = TRUE)

    if (!is.null(filter_column_name)){
        opt$filter = create_filter(filter_column_name)
    }

    if (is.null(opt$filter)){
        mymessages(c("No filter paramter provided so no filtering done"))
    } else {
        my_filter = parse(text=opt$filter)
        old_length = nrow(data)
        data = subset(data, eval(my_filter))
        new_length = nrow(data)
        if (new_length == old_length) {
            mymessages(c("applying filter",opt$filter,"had no effect"))
        } else if (new_length == 0){
            myerror(c(opt$filter,"has removed all the data"))
        } else {
            mymessages(c("applying filter",opt$filter,"has reduced the rows from", old_length,"to",new_length))
        }
        mysummary("data after filter", data)
    }
    return (data)
}

#Main

if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (filter_options())

    check_filter()

    data <- read_the_data(description="Input data")

    data = do_filter(data)

    write_the_data (data, "Filtered Data")

}



