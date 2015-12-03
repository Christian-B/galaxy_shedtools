mymessages <- function(mess_array, always=FALSE){
    if (opt$verbose | always) {
        cat(paste0(mess_array, collapse = " "))
        cat ("\n")
    }
}


myerror <- function(mess_array){
    print_help(option_parser)
    cat(paste0(mess_array, collapse = " "))
    cat ("\n")
    quit(status = 1)
}



check_the_variable <- function(long_name, optional=FALSE, minimum=NA, legal_values=list(), values_required=TRUE){
    if (is.null(opt[[long_name]])) {
        if (optional) {
            mymessages(c("No value provided for",long_name))
            return (FALSE)
        } else {        
            myerror(c("Parameter",long_name,"not provided"))
        }        
    } else {
        if (is.na(opt[[long_name]])) {
            myerror(c("Parameter",long_name,"provided with an invalid value!"))
        } else if (!is.na(minimum)){
            if (opt[[long_name]] < minimum){
                myerror(c("parameter",long_name,"must be at least",minimum,"found",opt[[long_name]]))
            }
        } else if (length(legal_values) > 0){
            if (! opt[[long_name]] %in% legal_values){
                value_st = paste(legal_values,collapse =", ")
                if (values_required){
                    myerror(c("parameter",long_name,"must be one of (",value_st,") found",opt[[long_name]])) 
                } else {
                    cat(paste("parameter",long_name,"not one of (",value_st,") found",opt[[long_name]],"This may cause an error!\n", collapse = " "))
                }               
            }
        }
        if (opt[[long_name]] == ""){
            mymessages (c(long_name,"has the value empty string"))
        } else {
            mymessages (c(long_name,"=",opt[[long_name]]))
        }
        return (TRUE)
    }
}


check_variable <- function(long_name, optional=FALSE, minimum=NA, legal_values=list(), values_required=TRUE){
    ignore <- check_the_variable(long_name, optional, minimum, legal_values, values_required)
}



check_variables <- function(flag_names, extra_names, optional=FALSE, qvalues=list(), values_required=TRUE) {
    flag_found = NULL 
    for (flag_name in flag_names){
        if (check_the_variable(flag_name, optional=TRUE, legal_values=qvalues[[flag_name]], values_required=values_required)){
            flag_found = flag_name
        }
    } 
    if (is.null(flag_found)){
        if (optional) {
            mymessages(c("No value provided for",extra_names[1]))
            for(extra_name in extra_names){
                if (is.null(opt[[extra_name]])) {
                    mymessages(c("No value provided for",extra_name))
                } else {
                    myerror(c("Parameter",extra_name,"provided but none of",paste(flag_names,sep=", "),"provided"))
                }
            }   
        } else {
            myerror(c("None of the parameters",paste(flag_names,collapse =", "),"provided"))
        }
    } else {
        for(extra_name in extra_names){
            if (is.null(opt[[extra_name]])) {
                myerror(c("Parameter",flag_found,"provided but parameter",extra_name,"is missing"))
            } else {
                check_variable(extra_name, legal_values=qvalues[[extra_name]],values_required=values_required)
            }   
        }
    }
}


check_column_by_number <- function(data, column_number){
    if (opt[[column_number]] < 1){
        myerror(c(column_number, ": ", opt[[column_number]],"must be great than zero!"))
    }
    if (opt[[column_number]] > length(colnames(data)) ){
        myerror(c(column_number, ": ", opt[[column_number]],"greater than data length",length(colnames(data)) ))
    }
    number <- opt[[column_number]]
    colname <- colnames(data)[[ number ]]
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


valid_input_formats = c("tsv","csv","excell")

check_input_format <- function(long_name) {
    check_variable(long_name)
    if (opt[[long_name]] %in% valid_input_formats){
        mymessages(c("\tReading is done with check.names = FALSE and blank.lines.skip = FALSEU"))
    } else {
        myerror(c("parameter",long_name,"not a valid input format. Use one of", valid_input_formats))
    }
}

read_the_data  <- function(description="Some data"){
    return (read_data(opt$input_file, table_format=opt$input_file_format, description=description, header=TRUE, na.strings = opt$input_na))
}

#Because default value for header differes between format this methods has no defualt header
#Overrides normal default check.names = TRUE and blank.lines.skip = TRUE
read_data  <- function(table_file, table_format, description, header, na.strings = "NA"){ 
    if (file.exists(table_file)){
        if (table_format == "tsv"){
            data <- read.table(table_file,
                               header = header, na.strings = na.strings, 
                               blank.lines.skip = FALSE, check.names=FALSE)
        } else if (table_format == "csv"){
            data <- read.csv(table_file,
                             header = header, na.strings = na.strings, 
                             blank.lines.skip = FALSE, check.names=FALSE)
        } else if (table_format == "excell"){
            data <- read.xls (opt$xls_file, sheet = 1, method="tab", 
                              header = header, na.strings = na.strings, 
                              blank.lines.skip = FALSE, check.names=FALSE)
        } else {
            myerror(c("Unexpected format",table_format,"for",description))
            stop(error_message)            
        }   
        mysummary(description, data)
        return (data)
    } else {
        myerror(c("File",table_file,"does not exist! So unable to read",description))
        stop(error_message)
    }
}

valid_output_formats = c("tsv","csv")

check_output_format <- function(long_name) {
    check_variable(long_name)
    if (opt[[long_name]] %in% valid_input_formats){
        mymessages(c("\tReading is done with check.names = FALSE and blank.lines.skip = FALSE"))
    } else if (opt[[long_name]] == "excell"){
        myerror(c("For parameter",long_name,"excell format not supported. Use csv or tsv which Excell can read"))
    } else {
        myerror(c("parameter",long_name,"not a valid input format. Use one of", valid_input_formats))
    }
}

#Overrides normal default quote=FALSE
write_the_data  <- function(data, decription="some data"){ 
    if (is.null(opt$data_output_file)){
        mymessages(c("No data output as data_output_file parameter not provided"))
    } else {
        write_data (data, table_file = opt$data_output_file, table_format= opt$data_output_format, description = decription, 
                    na=opt$output_na, row.names=TRUE, col.names=TRUE) 
    }
}

write_data <- function(data, table_file, table_format, description, na="NA", row.names=TRUE, col.names=TRUE){
    if (is.null(table_file)){
        mymessages(c(description, "not saved as file name not specified."))
    } else {
        if (table_format=="tsv"){
            write.table(data, table_file, sep='\t', 
                        row.names = row.names, col.names = col.names, na = na,
                        quote=FALSE)
        } else if (table_format == "csv"){
            write.csv(data, file = table_file, 
                      row.names = row.names, col.names = col.names, na = na,
                      quote=FALSE)
        }
        if (file.exists(table_file)){
            mymessages(c(description, "output to", table_file, "in",table_format,"format."))
        } else {
            myerror(c("Failed to write", description, "to", table, "."))
            stop(error_message)
        }
    }
}

remove_symbols <- function(text){
    if (is.character(text)){
        text <- gsub("__lt__","<",text)
        text <- gsub("__gt__",">",text)
        text <- gsub("__sq__","'",text)
        text <- gsub("__dq__",'"',text)
        text <- gsub("__in__",'%in%',text)
    }
    return (text)
}

mysize <- function(data) {
    dim_data = dim(data)
    if (!is.null(dim_data)){
        return (toString(dim_data))
    }
    if (length(data) == 1){
        return ("1")
    }
    the_size = mysize(data[[1]])
    for (i in 2:length(data)) {
        new_size = mysize(data[[i]])
        if (the_size !=  new_size){
        return(paste (paste(length(data),",", sep=""), "various", sep = " "))
        }
    }
    if (the_size == "1"){
        return (length(data))
    } else {
        return(paste (paste(length(data),",", sep=""), the_size, sep = " "))
    }
}


mysummary <- function(long_name, data) {
    if (opt$debug) {
        cat (long_name)
        cat (": class = ")
        cat (class(data))
        cat (": type = ")
        cat (typeof(data))
        cat (", size = ")
        cat (mysize(data))
        cat ("\n")
    }
}

input_options <- function(){
    new_options = list(
        make_option("--input_file", action="store", type='character',
                    help="File to read data from"),
        make_option("--input_file_format", action="store", type='character', default="tsv",
                    help="Format of file to read data from. Excepted values are tsv, csv, excell. Default is tsv"),
        make_option("--input_na", action="store", type='character', 
                    help="Value that should be read in as NA. Leave blank to considered the empty string as NA.")
    )
    return (new_options)
}

output_options <- function(){
    new_options = list(
        make_option("--data_output_file", action="store", type='character', 
                    help="File to write reduced data to. if not provided no data will be putput."),
        make_option("--data_output_format", action="store", type='character', default="tsv",
                    help="Format of file to write data to. Excepted values are tsv, csv, excell. Default is tsv"),
        make_option("--output_na", action="store", type='character', default=NULL,
                    help="Value that should be used for any NA in the output file. If not provided the empty string is used.")
    )
    return (new_options)
}

util_options <- function(){
    new_options = list(
        make_option("--script_dir", action="store", type='character',
                    help="Path to the where R utils scripts are stored. If not the current directory"),
        make_option("--verbose", action="store_true", default=FALSE,
                    help="Should the program print extra stuff out? [default %default]"),
        make_option("--debug", action="store_true", default=FALSE,
                    help="Should the program print even more extra stuff out? [default %default]. Setting debug turns verbose on too!")
    )
    return (new_options)
}

check_utils  <- function(){ 
    if (opt$debug) { 
        opt$verbose <<- TRUE 
    }
    mymessages(c("Parameters provided as"))
}

check_inputs  <- function(){ 
    check_variable("input_file")
    check_input_format("input_file_format")
    if (is.null(opt$input_na)){
        opt$input_na <<- ""
    }
    check_variable("input_na")
}

check_output  <- function(){ 
    check_variable("data_output_file", optional=TRUE)
    check_output_format("data_output_format")
    if (!is.null(opt$data_output_file)){
        if (is.null(opt$output_na)){
            opt$output_na <<- ""
        }
        check_variable("output_na")
    }
}

init_utils <- function(extra_options){
    option_list <- c(input_options(), extra_options, output_options(), util_options())    

    option_parser <<- OptionParser(option_list=option_list)
    opt <<- parse_args(option_parser)

    check_utils()
    check_inputs()
    check_output()
}


