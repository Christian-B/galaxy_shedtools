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

heatplot_options <- function(){
    new_list = list(
        make_option("--heatplot_dend", action="store", type='character',
                    help="dend paramteter for heatplot. Known legal values are both, row, column, and none"),
        make_option("--heatplot_cexrow", action="store", type='double',
                    help="cexRow parameter for heatplot"),
        make_option("--heatplot_cexcol", action="store", type='double', 
                    help="cexCol parameter for heatplot")
    )
    return (c(graph_options(), new_list))
}

check_heatplot  <- function(){ 
    check_graph()
    if (!is.null(opt$graph_file)){
        check_variable("heatplot_dend", optional=TRUE, legal_values=c("both", "row", "column", "none"), values_required=FALSE)
        check_variable("heatplot_cexrow", optional=TRUE)
        check_variable("heatplot_cexcol", optional=TRUE)
    }
}


heatplot_data <- function(data){
    if (is.null(opt$graph_file)){
        mymessages(c("No graph plotted as graph_file parameter not provided"))
    } else {
        graph_start()
        heatplot(data, dend=opt$heatplot_dend, cexRow=opt$heatplot_cexrow, cexCol=opt$heatplot_cexcol)
        graph_end()
    }
}

#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (heatplot_options())

    check_heatplot()

    data <- read_the_data(description="Extracted Data")

    heatplot_data(data)

}
