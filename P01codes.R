library(tidyverse)

P01file<-"data/P01_subcomponentsx.txt" # UTF-8 (BOM)

# load file containing list of P01 components
dfP01 <- read.table(P01file,header=T,sep="\t",stringsAsFactors=F,fileEncoding="UTF-8",comment.char="",quote="",allowEscapes=F,na.strings="NULL",fill=T)

dfP01$P01PrefLabel[1]
dfP01$P01PrefLabel[13897]

#"Concentration of benzo(g,h,i)perylene {CAS 191-24-2} per unit dry weight of biota {Zoarces viviparus (ITIS: 165324: WoRMS 127123)}"
df <- dfP01 %>% distinct(S02PrefLabel)
df <- dfP01 %>% distinct(S25PrefLabel)

# S27PrefLabel - substance
# CAS - CAS
# S02PrefLabel - dimensions of measurement
# S25PrefLabel - species
# S26PrefLabel - particle
# S03PrefLabel - extraction method
# S04PrefLabel - measurement method
# S05PrefLabel - calculation method
# S06PrefLabel - measurement
# S07PrefLabel - statistic

df <- dfP01 %>% distinct(S06PrefLabel) 


df2<-NULL
i<-0
for(n in names(dfP01)){
  i<-i+1
  df <- dfP01 %>% distinct_(n) 
  df$column<-names(df)[1]
  names(df)[1]<-"value"
  df <- df %>% 
    filter(!is.na(value)) %>%
    select(column,value)
  if(i<7){
    df2<-df
  }else{
    df2 <- df2 %>% bind_rows(df)
  }
}
  
  