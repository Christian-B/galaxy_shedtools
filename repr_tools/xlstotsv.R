suppressPackageStartupMessages(require(gdata))
suppressPackageStartupMessages(require(optparse))
 
not_all_blank <- function(a_vector){
    all_blank = all(unlist(lapply(a_vector, function(x) {x == ""})))
    return (!all_blank)
}

option_list = list(
  make_option("--xls_file", action="store", type='character', 
              help="xls file to read data from"),
  make_option("--ignore_rows", action="store", type='integer', default=0, 
              help="Number of rows to ignore (including blank lines) at the top of the workbook. These will be assumed to be the metadata."),
  make_option("--names_rows", action="store", type='integer', default=0,
              help="Number of rows below which include info to combine into names. These are assumed to be below the ignore rows"),
  make_option("--raw_tsv_file", action="store", type='character', 
              help="Raw converted tsv file. (Optional)."),
  make_option("--meta_data_file", action="store", type='character', 
              help="File to store metadata header into. (Optional)."),
  make_option("--tsv_output_file", action="store", type='character', 
              help="tsv file to output data to."),
  make_option(c("--script_dir"), action="store", type='character',
              help="Path to the where R utils scripts are stored. If not the current directory"),

  make_option(c("--verbose"), action="store_true", default=FALSE,
              help="Should the program print extra stuff out? [default %default]"),
  make_option(c("--debug"), action="store_true", default=FALSE,
              help="Should the program print even more extra stuff out? [default %default]. Setting debug turns verbose on too!")
)

option_parser = OptionParser(option_list=option_list)
opt = parse_args(option_parser)

if(!exists("check_variable", mode="function")) {
    if (is.null(opt$script_dir)){
        source("brenninc_util.R")
    } else {
        source(paste0(c(opt$script_dir,"brenninc_utils.R"), collapse = "/"))
    }
}
if (opt$debug) { opt$verbose=TRUE }
check_variable("xls_file")
check_variable("raw_tsv_file", optional = TRUE)
check_variable("ignore_rows", minimum = 0)
check_variable("meta_data_file", optional = TRUE)
check_variable("names_rows", minimum = 0)
check_variable("tsv_output_file")

# Reading data from CSV file
if (file.exists(opt$xls_file)){
    data <- read.xls (opt$xls_file, sheet = 1, header = FALSE, blank.lines.skip = FALSE, method="tab")
    mysummary("data read", data)
} else {
    myerror(c("File",opt$xls_file,"does not exist"))
    stop(error_message)
}

write_tsv(data, opt$raw_tsv_file, description="Raw data")

if (opt$ignore_rows >= 1){
    data_minus = data[c(1:opt$ignore_rows),]
    write_tsv(data_minus, opt$meta_data_file, description="Meta data")
    data_minus_ignores = data[-c(1:opt$ignore_rows),]
    mysummary("data_minus_ignores", data_minus_ignores)
    data_less_ignores = data_minus_ignores[sapply(data_minus_ignores,not_all_blank)]
} else {
    data_less_ignores = data
} 
mysummary("data_less_ignores", data_less_ignores)

if (opt$names_rows >= 1){
    names_rows = data_less_ignores[c(1:opt$names_rows),]
    mysummary("name_rows", names_rows)
    the_names = sapply( names_rows, function(x) {gsub(" ","_",(paste(x[[1]], x[[2]], x[[3]], sep="_")))})
    mysummary("the_names",the_names)
    headed_data = data_less_ignores[-c(1:opt$names_rows),]
    colnames(headed_data) <- the_names
} else {
    headed_data = data_less_ignores
    colnames(headed_data) <- NULL
}
mysummary("headed_data", headed_data)

write_tsv(headed_data, opt$tsv_output_file, description="Cleaned data", col.names=TRUE)



