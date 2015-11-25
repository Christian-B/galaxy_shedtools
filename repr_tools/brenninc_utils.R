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



check_variable <- function(long_name, optional=FALSE, minimum=NA) {
    if (is.null(opt[[long_name]])) {
        if (optional) {
            mymessages(c("No value provided for",long_name))
        } else {        
            myerror(c("Parameter",long_name,"not provided"))
        }        
    } else {
        if (is.na(opt[[long_name]])) {
            myerror(c("Parameter",long_name,"provided with an invalid value!"))
        } else if (!is.na(minimum)){
            if (opt[[long_name]] < minimum){
                myerror(c("parameter",long_name,"must be at least",minimum))
            }
        }
        if (opt[[long_name]] == ""){
            mymessages (c(long_name,"has the value empty string"))
        } else {
            mymessages (c(long_name,"=",opt[[long_name]]))
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


