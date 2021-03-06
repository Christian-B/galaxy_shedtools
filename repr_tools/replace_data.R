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
 
replace_options <- function(){
    new_options = list(
        make_option("--replace_value", action="store", type='character', default=NULL,
                    help="Value to replace any filtered values by")
    )
    return (c(global_filter_options(), new_options))
}

check_replace <- function(){ 
    check_global_filter()
    opt$replace_value <<- remove_symbols(opt$replace_value)
    check_variable("replace_value")
}

do_replace  <- function(data){ 
    filter = create_filter("data")
    my_filter = parse(text=filter)
    data[eval(my_filter)] = opt$replace_value
    mysummary("data after filter", data)
    return (data)
}

#Main

if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (replace_options())

    check_replace()

    data <- read_the_data(description="Input data")

    data = do_replace(data)

    write_the_data (data, "Replaced Data")

}



