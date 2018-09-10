## processing EMODnet chemistry data
library(tidyverse)

source("convert.R")

EMODNETfile<-"data/Black_Sea_BIOTA.txt" 

df <- convert(EMODNETfile)



P01file <- "EMDchem_BlkSea_MedSea_P01_20180523.txt"

# load file containing list of P01 components
P01file<-"data/P01_subcomponentsx.txt" # UTF-8 (BOM)

dfP01 <- read.table(P01file,header=T,sep="\t",stringsAsFactors=F,fileEncoding="UTF-8",comment.char="",quote="\'" ,allowEscapes=F,na.strings = "NULL",fill=T)



# 1252
