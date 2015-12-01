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
 
graph_options <- function(){
    new_list = list(
        make_option("--graph_file", action="store", type='character', 
                    help="File to write graph to. If not provided no graph is output"),
        make_option("--graph_height", action="store", type='double', default="10",
                    help="Height in inches of graph"),
        make_option("--graph_width", action="store", type='double', default="10",
                    help="Width in inches of graph"),
        make_option("--graph_title", action="store", type='character',
                    help="Title to give the graph. If no title is provided one will be created automatically."),
        make_option("--graph_red_line_value", action="store", type='double', 
                    help="Value at which to draw a horizonatal red line. If not provided no line is draw")
    )
    return (new_list)
}

check_graph  <- function(){ 
    check_variable("graph_file", optional=TRUE)
    if (!is.null(opt$graph_file)){
        check_variable("graph_height")
        check_variable("graph_width")
        check_variable("graph_red_line_value", optional=TRUE)
        if (is.null(opt$graph_title)) {
            opt$graph_title <<- paste(opt$value,"by",opt$row_name)
        }
        check_variable("graph_title")
    }
}

graph_data <- function(data){
    if (is.null(opt$graph_file)){
        mymessages(c("No graph plotted as graph_file parameter not provided"))
    } else {
        postscript(opt$graph_file, horizontal=F, width=opt$graph_width, height=opt$graph_height, paper="special", onefile=FALSE)
        #jpeg(filename = opt$graph_file, width = opt$graph_width, height = opt$graph_height, units = "in", pointsize = 12, quality = 75,
        #     bg = "white", res = 300, bitmapType='cairo')
        #png(filename = opt$graph_file, width = opt$graph_width, height = opt$graph_height, units = "in", pointsize = 12, bg = "white", res = 300)
        old.par <- par(mfrow=c(2, 1)) 
        par(cex.axis=0.55)
        boxplot(data,ylab="Ct Value", names=colnames(data), las=2,font.axis=0.5)
        title(opt$graph_title)
        if (is.null(opt$graph_red_line_value)){
            mymessages(c("No red line as graph_red_line_value parameter not provided"))  
        } else {
            abline(h=opt$graph_red_line_value, col="red", lwd=3)
        }
        done = dev.off()
        mymessages(c("Plotted graph to",opt$graph_file))
    }
}

#Main
if (!exists("main_flag")){
    main_flag <<- TRUE

    load_utils()

    init_utils (graph_options())

    check_graph()

    data <- read_the_data(description="Extracted Data")

    graph_data(data)

}
