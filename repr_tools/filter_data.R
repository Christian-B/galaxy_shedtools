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
 
symbols <- c("==","!=","<","<=",">",">=")

filter_options <- function(){
    symbols_option <- "(Optional: Use __gt__ and __lt__ for < and >) "
    help_filter = paste("One or more filter to apply to the data. ",
                        "Seperate filters can be divided by commas. ",
                        symbols_option,
                       "No other filter_** parameter needs to be provided.", sep="")
    help_symbol = paste("Symbol for the filter. ",
                        paste("Recommended symbols are (",paste(symbols,collapse =", "),") "),
                        "The symbol will be applied column symbol value. ",
                        symbols_option, 
                        'This parmater may not work if you use the --filter_symbol="==" format. Use the --filter_symbol "==" format', 
                        sep="")
    new_options = list(
        make_option("--filter", action="store", type='character', default=NULL,
                    help=help_filter),   
        make_option("--filter_column_name", action="store", type='character', default=NULL,
                    help="Name of the column to filter on."),
        make_option("--filter_column_number", action="store", type='integer', default=NULL,
                    help="Number the column to filter on."),
        make_option("--filter_symbol", action="store", type='character', default=NULL,
                    help=help_symbol),
        make_option("--filter_value", action="store", type='character', default=NULL,
                    help="One or more filter to apply to the data")
    )
    return (new_options)
}

check_filter  <- function(){ 
    opt$filter <<- remove_symbols(opt$filter)
    check_variable("filter", optional=TRUE)
    values<-list()
    values[[1]] <- symbols
    names(values) <- c("filter_symbol")
    opt$filter_symbol <<- remove_symbols(opt$filter_symbol)
    check_variables(c("filter_column_name","filter_column_number"),c("filter_symbol","filter_value"), optional=TRUE, qvalues=values, values_required=FALSE)
}

do_filter  <- function(data){ 
    filter_column_name <- check_column(data, "filter_column_name", "filter_column_number", optional = TRUE)

    if (!is.null(filter_column_name)){
        filter = paste(filter_column_name, opt$filter_symbol, opt$filter_value, collapse ="")
        if (is.null(opt$filter)){
            opt$filter = filter
        } else {
            opt$filter = paste(opt$filter, filter, collapse =",")
        }
        mymessages(c("Filter set to ", opt$filter))
    }

    if (is.null(opt$filter)){
        mymessages(c("No filter paramter provided so no filtering done"))
    } else {
        for (a_filter in strsplit(opt$filter, ",")[[1]]){
            my_filter = parse(text=a_filter)
            old_length = nrow(data)
            data = subset(data, eval(my_filter))
            new_length = nrow(data)
            if (new_length == old_length) {
                mymessages(c("applying filter",a_filter,"had no effect"))
            } else if (new_length == 0){
                myerror(c(a_filter,"has removed all the data"))
            } else {
                mymessages(c("applying filter",a_filter,"has reduced the rows from", old_length,"to",new_length))
            }
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



