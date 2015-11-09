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


write_tsv <- function(data, tsv_file, description="Some data", col.names = FALSE){
    if (is.null(tsv_file)){
        mymessages(c(description, "not saved as file name not specified."))
    } else {
        write.table(data, tsv_file, quote=FALSE, sep='\t', row.names = FALSE, col.names = col.names)
        if (file.exists(tsv_file)){
            mymessages(c(description, "output to", opt$raw_tsv_file, "in tsv format."))
        } else {
            myerror(c("Failed to write", description, "to", opt$raw_tsv_file,"."))
            stop(error_message)
        }
    }
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
        mymessages (c(long_name,"=",opt[[long_name]]))
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


