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

boxplot_options <- function(){
    new_list = list(
        make_option("--boxplot_title", action="store", type='character',
                    help="Title to give the graph."),
        make_option("--boxplot_y_label", action="store", type='character',
                    help="Label for the Y axis in the graph."),
        make_option("--boxplot_red_line_value", action="store", type='double', 
                    help="Value at which to draw a horizonatal red line. If not provided no line is draw")
    )
    return (c(graph_options(), new_list))
}

check_boxplot  <- function(){ 
    check_graph()
    if (!is.null(opt$graph_file)){
        check_variable("boxplot_red_line_value", optional=TRUE)
        check_variable("boxplot_title", optional=TRUE)
        check_variable("boxplot_y_label", optional=TRUE)
    }
}

boxplot_data <- function(data){
    if (is.null(opt$graph_file)){
        mymessages(c("No graph plotted as graph_file parameter not provided"))
    } else {
        graph_start()
        old.par <- par(mfrow=c(2, 1)) 
        par(cex.axis=0.55)
        boxplot(data,ylab=opt$boxplot_y_label, names=colnames(data), las=2,font.axis=0.5)
        title(opt$boxplot_title)
        if (is.null(opt$boxplot_red_line_value)){
            mymessages(c("No red line as graph_red_line_value parameter not provided"))  
        } else {
            abline(h=opt$boxplot_red_line_value, col="red", lwd=3)
        }
        graph_end()
    }
}

#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (boxplot_options())

    check_boxplot()

    data <- read_the_data(description="Extracted Data")

    boxplot_data(data)

}
