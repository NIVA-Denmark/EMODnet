## processing EMODnet chemistry data

library(tidyverse)

# load file containing list of P01 components
P01file<-"data/P01_subcomponents.txt" # UTF-8 (BOM)

#dfP01 <- read.table(P01file,header=T,sep="\t",stringsAsFactors=F,encoding="UTF-8",comment.char="",skip=2650,allowEscapes=F,na.strings = "NULL")
dfP01 <- read.table(P01file,header=T,sep="\t",stringsAsFactors=F,encoding="UTF-8",comment.char="",allowEscapes=F,na.strings = "NULL")


"data_from_Mediterranean_Biota_Contaminants.txt" # 1252
"data_from_Mediterranean_Biota_Contaminants_Time_series.txt" # 1252
"Black_Sea_BIOTA.txt" # 1252

dfP01[2651,1]
