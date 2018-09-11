## processing EMODnet chemistry data
library(tidyverse)

source("convert.R")
source("Read_P01_table.R")
folder<-"data/"

EMODNETfile<-"Black_Sea_BIOTA.txt" 
df1<- convert(paste0(folder,EMODNETfile),infocols=c(2,4,5,6)) %>%
  left_join(dfP01,by="P01") %>%
  mutate(srcfile=EMODNETfile)

EMODNETfile<-"data_from_Mediterranean_Biota_Contaminants.txt"
df2<- convert(paste0(folder,EMODNETfile),infocols=c(2,4,5,6)) %>%
  left_join(dfP01,by="P01") %>%
  mutate(srcfile=EMODNETfile)

EMODNETfile<-"data_from_Mediterranean_Biota_Contaminants_Time_series.txt"
df3<- convert(paste0(folder,EMODNETfile),infocols=c(2,4,5,6),timeseries=T,dropmissing=T) %>%
  left_join(dfP01,by="P01") %>%
  mutate(srcfile=EMODNETfile)

df<-bind_rows(mutate_all(df1, as.character),
              mutate_all(df2, as.character),
              mutate_all(df3, as.character))

write.table(df,file="EMODNET_contaminants.txt",row.names=FALSE,quote=FALSE,sep='\t',na="")

