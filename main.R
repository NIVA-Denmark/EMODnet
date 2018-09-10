## processing EMODnet chemistry data
library(tidyverse)

source("convert.R")
source("P01codes.R")

EMODNETfile<-"data/Black_Sea_BIOTA.txt" 
EMODNETfile<-"data/data_from_Mediterranean_Biota_Contaminants.txt"
EMODNETfile<-"data/data_from_Mediterranean_Biota_Contaminants_Time_series.txt"

df <- convert(EMODNETfile)

keep <- c("P01","Measurement","MeasBasis",
          "MeasShort","Matrix","CAS",
          "Substance","SubstanceShort",
          "Species","Sex","Subcomponent")

dfP01 <- P01() %>% 
  select(keep)

keep <- c("Station","yyyy-mm-ddThh:mm:ss.sss",
          "Longitude [degrees_east]","Latitude [degrees_north]",
          "value","quality","P01")

df <- df %>%
  select(keep) %>%
  left_join(dfP01,by="P01")