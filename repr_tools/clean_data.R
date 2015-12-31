suppressPackageStartupMessages(require(gdata))
 
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
  
clean_options <- function(){
    new_options = list(
        make_option("--ignore_rows", action="store", type='integer', default=0, 
                    help="Number of rows to ignore (including blank lines) at the top of the workbook. These will be assumed to be the metadata."),
        make_option("--names_rows", action="store", type='integer', default=0,
                    help="Number of rows below which include info to combine into names. These are assumed to be below the ignore rows"),
        make_option("--meta_data_file", action="store", type='character', 
                    help="File to store metadata header into. (Optional).")
    )
    return (new_options)
}

check_clean  <- function(){ 
    check_variable("ignore_rows", minimum = 0)
    check_variable("ignore_rows", minimum = 0)
    check_variable("meta_data_file", optional = TRUE)
    check_variable("names_rows", minimum = 0)
}

ignore_top_lines <- function(data){ 
    if (opt$ignore_rows >= 1){
        meta_data = data[c(1:opt$ignore_rows),]
        write_data (meta_data, opt$meta_data_file, table_format = "tsv", description="Meta data", na=opt$output_na, row.names=FALSE, col.names=FALSE)
        data = data[-c(1:opt$ignore_rows),]
        mysummary("data_minus_ignores", data)
    }
    data = data[sapply(data,not_all_blank)]
    mysummary("data_less_empty_rows", data)
    return (data)
} 

as_character_NA_as_blank <- function(input){
    aschar <- sapply(input, as.character)
    aschar[is.na(aschar)] = ""
    return (aschar)
}

make_header <- function(data){ 
    if (opt$names_rows >= 1){
        names_rows = data[c(1:opt$names_rows),]
        mysummary("name_rows", names_rows)
        the_names = sapply( names_rows, function(x) {gsub(" ","_",(paste(as_character_NA_as_blank(x), collapse ="_")))})
        mysummary("the_names",the_names)
        data <- data[-c(1:opt$names_rows),]
        the_names <- sapply(the_names, clean_name)
        the_names <- make.names(the_names, unique = TRUE)
        colnames(data) <- the_names
    } else {
        colnames(data) <- NULL
    }
    mysummary("headed_data", data)
    return (data)
}

if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (clean_options())

    check_clean()

    data <- read_the_data(description="Input data")

    data = ignore_top_lines(data)

    data = make_header(data)

    write_the_data (data, "Cleaned Data", row.names=TRUE, col.names=TRUE)

}


