library(Rcpp)

args<-commandArgs(TRUE)
writeLines(capture.output(sessionInfo()), args[1])
sessionInfo()
