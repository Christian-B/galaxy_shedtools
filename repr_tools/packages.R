library(ade4)
library(RColorBrewer)
library(gtools)
library(gdata)
library(bitops)
library(caTools)
library(KernSmooth)
library(gplots)
library(scatterplot3d)
library(made4)
library(impute)
library(highr)
library(repr)
library(getopt)
library(optparse)

args<-commandArgs(TRUE)
writeLines(capture.output(sessionInfo()), args[1])
sessionInfo()

capabilities()


