library(scde)

args = commandArgs(trailingOnly = TRUE)
es_mef_file = args[1]
print(paste("Reading es.mef from",es_mef_file, sep = " "))
o_ifm_file = args[2]
print(paste("Will write o.ifm to",o_ifm_file, sep = " "))


# load example dataset
es.mef.small = read.csv(es_mef_file, row.names=1)

head(es.mef.small)
str(es.mef.small)

# factor determining cell types
sg <- factor(gsub("(MEF|ESC).*", "\\1", colnames(es.mef.small)), levels = c("ESC", "MEF"))
# the group factor should be named accordingly
names(sg) <- colnames(es.mef.small)  
table(sg)

# clean up the dataset
cd <- es.mef.small
# omit genes that are never detected
cd <- cd[rowSums(cd)>0, ]
# omit cells with very poor coverage
cd <- cd[, colSums(cd)>1e4]

# EVALUATION NOT NEEDED
# calculate models
o.ifm <- scde.error.models(counts = cd, groups = sg, n.cores = 1, threshold.segmentation = TRUE, save.crossfit.plots = FALSE, save.model.plots = FALSE, verbose = 1)

write.csv(o.ifm,file=o_ifm_file)
print(paste("Wrote write o.ifm to",o_ifm_file, sep = " "))

