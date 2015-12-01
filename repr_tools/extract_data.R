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
 
extract_options <- function(){
    new_list = list(
        make_option("--value", action="store", type='character', 
                    help="Name of column which holds the values to extract and plot to the graph"),
        make_option("--value_col", action="store", type='integer', 
                    help="Number of column which holds the values to extract and plot to the graph"),
        make_option("--column_names", action="store", type='character', 
                    help="Name of column which holds the data to be used as column names in the extracted data and X axis of the graph"),
        make_option("--column_names_col", action="store", type='integer', 
                    help="Number of column which holds the data to be used as column names in the extracted data and X axis of the graph"),
        make_option("--row_names", action="store", type='character', 
                    help="Name of column which holds the names to be used as rows in the extracted data"),
        make_option("--row_names_col", action="store", type='integer',
                    help="Number of column which holds the names to be used as rows in the extracted data")
    )
    return (new_list)
}

check_filter  <- function(){ 
    check_variable("value", optional=TRUE)
    check_variable("value_col", optional=TRUE, minimum=1)
    check_variable("row_names", optional=TRUE)
    check_variable("row_names_col", optional=TRUE, minimum=1)
    check_variable("column_names", optional=TRUE)
    check_variable("column_names_col", optional=TRUE, minimum=1)
}


extract_the_values <- function(data){
    value <- check_column(data, "value", "value_col")
    column_names <- check_column(data, "column_names", "column_names_col")
    row_names <- check_column(data, "row_names", "row_names_col", optional = TRUE)
    return ( extract_values(data, value, column_names, row_names) )
}
  
extract_values <- function(data, value, column_names, row_names){
    if (is.null(row_names)){
        return (extract_values_simple(data, value, column_names))
    }
    tryCatch({
        return (extract_values_with_row_names(data, value, column_names, row_names)) 
    }, error = function(err) {
        mymessages(c("Error extracting values with row names:  ",err,"\nExtracting values without row names"),always=TRUE)
        return (extract_values_simple(data, value, column_names))
    }) 
}

extract_values_with_row_names <- function(data, value, column_names, row_names){
    data_list <- split(data , f = (factor(data[[column_names]])) )
    mysummary("data_list", data_list)

    if (all(unlist(lapply(data_list, function(x){length(unique(x[[row_names]])) == length(x[[row_names]])})))){
        two_list = lapply(data_list, function(x){subset(x, select=c(value, row_names))})
        #Change the names of the second column in each list to the column_name that it was split on above.
        for (i in 1:length(two_list)) {
            colnames(two_list[[i]])[colnames(two_list[[i]]) == value] <- names(two_list)[[i]]
        }
        mysummary("two_list", two_list)

        merged_list = Reduce(function(...) merge(..., all=T), two_list)
        rownames(merged_list) <- merged_list[,row_names]
        #Delete the column holding the rows names (that was used to merge on)
        merged_list[row_names] <- NULL
        mysummary("merged_list", merged_list)
        return (as.matrix(merged_list))
    } else {
        stop("Duplicates vaues where found for values with row and column name")
    }   
}

extract_values_simple <- function(data, value, column_names){
    data_list <- split(data , f = data[column_names] )
    merged_list = matrix(unlist(lapply(data_list, function(y)y[,value])), ncol=length(data_list), byrow=TRUE)
    colnames(merged_list) <- names(data_list)
    mysummary("merged_list", merged_list)
    return (merged_list)    
}


#Main
load_utils()

init_utils (extract_options())

check_filter()

data <- read_the_data(description="Input data")

data <- extract_the_values(data)

write_the_data (data, "Extracted Data")




