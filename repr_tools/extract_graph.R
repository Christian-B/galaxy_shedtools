suppressPackageStartupMessages(require(made4))
suppressPackageStartupMessages(require(impute))
suppressPackageStartupMessages(require(repr))
suppressPackageStartupMessages(require(optparse))
 

check_column_by_number <- function(data, column_number){
    if (opt[[column_number]] < 1){
        myerror(c(column_number, ": ", opt[[column_number]],"must be great than zero!"))
    }
    if (opt[[column_number]] > length(colnames(data)) ){
        myerror(c(column_number, ": ", opt[[column_number]],"greater than data length",length(colnames(data)) ))
    }
    colname <- colnames(data)[[ opt[[column_number]] ]]
    mymessages (c(column_number,opt[[column_number]],"maps to",colname))
    return (colname)
}


check_column_by_name <- function(data, column_name) {
    found <- match(opt[[column_name]], colnames(data))
    if(is.na(found)){
        myerror(c("No Colomn",column_name, "named", opt[[column_name]], "found in the data!"))
    } 
    mymessages(c(column_name,":",opt[[column_name]],"found in the data!"))
    return (opt[[column_name]])
}


check_column <- function(data, column_name, column_number, optional = FALSE) {
    if (is.null(opt[[column_name]])){
        if (is.null(opt[[column_number]])){
            if (optional) {
                return (NULL)
            } else {
                myerror(c("Neither",column_name, "nor", column_number, "parameter provided!"))
            }
        } else {
            return (check_column_by_number(data, column_number))
        } 
    } else {  
        if (is.null(opt[[column_number]])){
            return (check_column_by_name(data, column_name))
        } else {
            by_number = check_column_by_number(data, column_number)
            if (by_number == opt[[column_name]]){
                return (by_number)
            } else {
                error_message1 = c("Column", column_number,":", opt[[column_number]],"is named to",by_number)
                error_message2 = c("Which does not match",column_name, ":", opt[[column_name]])
                myerror(c(error_message1,error_message2))
            }
        }
    }
}


extract_values <- function(data, value, column_names, row_names){
    if (is.null(row_names)){
        return (extract_values_simple(data, value, column_names))
    }
    tryCatch({
        extract_values_with_row_names(data, value, column_names, row_names) 
    }, error = function(err) {
        mymessage(c("Error extracting values with row names:  ",err,"\nExtracting values without row names"),always=TRUE)
        return (extract_values_simple(data, value, column_names))
    }) 
}


extract_values_with_row_names <- function(data, value, column_names, row_names){
    data_list <- split(data , f = data[column_names] )
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

option_list = list(
  make_option("--input_file", action="store", type='character',
              help="File to read data from"),
  make_option("--input_file_format", action="store", type='character', default="tsv",
              help="Format of file to read data from. Excepted values are tsv, csv, excell. Default is tsv"),
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
              help="Number of column which holds the names to be used as rows in the extracted data"),
  make_option("--filter", action="store", type='character', default=NULL,
              help="One or more filter to apply to the data"),
  make_option("--input_na", action="store", type='character', 
              help="Value that should be read in as NA. Leave blank to considered the empty string as NA."),
  make_option("--data_output_file", action="store", type='character', 
              help="File to write reduced data to. if not provided no data will be putput."),
  make_option("--data_output_format", action="store", type='character', default="tsv",
              help="Format of file to write data to. Excepted values are tsv, csv, excell. Default is tsv"),
  make_option("--output_na", action="store", type='character', default=NULL,
              help="Value that should be used for any NA in the output file. If not provided the empty string is used."),
  make_option("--graph_file", action="store", type='character', 
              help="File to write graph to. If not provided no graph is output"),
  make_option("--graph_height", action="store", type='double', default="10",
              help="Height in inches of graph"),
  make_option("--graph_width", action="store", type='double', default="10",
              help="Width in inches of graph"),
  make_option("--graph_title", action="store", type='character',
              help="Title to give the graph. If no title is provided one will be created automatically."),
  make_option("--graph_red_line_value", action="store", type='double', 
              help="Value at which to draw a horizonatal red line. If not provided no line is draw"),

  make_option(c("--script_dir"), action="store", type='character',
              help="Path to the where R utils scripts are stored. If not the current directory"),
  make_option(c("--verbose"), action="store_true", default=FALSE,
              help="Should the program print extra stuff out? [default %default]"),
  make_option(c("--debug"), action="store_true", default=FALSE,
              help="Should the program print even more extra stuff out? [default %default]. Setting debug turns verbose on too!")
)

option_parser = OptionParser(option_list=option_list)
opt = parse_args(option_parser)

if (opt$debug) { opt$verbose=TRUE }

if(!exists("check_variable", mode="function")) {
    if (is.null(opt$script_dir)){
        source("brenninc_util.R")
    } else {
        source(paste0(c(opt$script_dir,"brenninc_utils.R"), collapse = "/"))
    }
}

if (opt$debug) { opt$verbose=TRUE }
mymessages(c("Parameters provided as"))
check_variable("input_file")
check_input_format("input_file_format")
check_variable("value", optional=TRUE)
check_variable("value_col", optional=TRUE, minimum=1)
check_variable("row_names", optional=TRUE)
check_variable("row_names_col", optional=TRUE, minimum=1)
check_variable("column_names", optional=TRUE)
check_variable("column_names_col", optional=TRUE, minimum=1)
check_variable("filter", optional=TRUE)
if (is.null(opt$input_na)){
    opt$input_na = ""
}
check_variable("input_na")
check_variable("data_output_file", optional=TRUE)
check_output_format("data_output_format")
if (!is.null(opt$data_output_file)){
    if (is.null(opt$output_na)){
        opt$output_na = ""
    }
    check_variable("output_na")
}
check_variable("graph_file", optional=TRUE)
if (!is.null(opt$graph_file)){
    check_variable("graph_height")
    check_variable("graph_width")
    check_variable("graph_red_line_value", optional=TRUE)
    if (is.null(opt$graph_title)) {
        opt$graph_title <- paste(opt$value,"by",opt$row_name)
    }
    check_variable("graph_title")
}

capabilities()

data <- read_data(opt$input_file, table_format=opt$input_file_format, description="Input data", header=TRUE, na.strings = opt$input_na)

value <- check_column(data, "value", "value_col")
column_names <- check_column(data, "column_names", "column_names_col")
row_names <- check_column(data, "row_names", "row_names_col", optional = TRUE)

if (!is.null(opt$filter)){
    for (a_filter in strsplit(opt$filter, ",")[[1]]){
        print (a_filter)
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
} else {
    mymessages(c("No filter paramter provided so no filtering done"))
}

merged_list = extract_values(data, value, column_names, row_names)

if (is.null(opt$data_output_file)){
    mymessages(c("No data output as data_output_file parameter not provided"))
} else {
    write_data (merged_list, table_file = opt$data_output_file, table_format= opt$data_output_format, description = "Marged Data", 
                na=opt$output_na, row.names=TRUE, col.names=TRUE) 
}

if (is.null(opt$graph_file)){
    mymessages(c("No graph plotted as graph_file parameter not provided"))
} else {
    postscript(opt$graph_file, horizontal=F, width=opt$graph_width, height=opt$graph_height, paper="special", onefile=FALSE)
    #jpeg(filename = opt$graph_file, width = opt$graph_width, height = opt$graph_height, units = "in", pointsize = 12, quality = 75,
    #     bg = "white", res = 300, bitmapType='cairo')
    #png(filename = opt$graph_file, width = opt$graph_width, height = opt$graph_height, units = "in", pointsize = 12, bg = "white", res = 300)
    old.par <- par(mfrow=c(2, 1)) 
    par(cex.axis=0.55)
    boxplot(merged_list,ylab="Ct Value", names=colnames(merged_list), las=2,font.axis=0.5)
    title(opt$graph_title)
    if (is.null(opt$graph_red_line_value)){
        mymessages(c("No red line as graph_red_line_value parameter not provided"))  
    } else {
        abline(h=opt$graph_red_line_value, col="red", lwd=3)
    }
    done = dev.off()
    mymessages(c("Plotted graph to",opt$graph_file))
}


