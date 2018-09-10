
P01<-function(){
  require(tidyverse)
  require(stringr)
  P01file<-"data/P01_subcomponents.txt" # UTF-8 (BOM)
  
  # load file containing list of P01 components
  df <- read.table(P01file,header=T,sep="\t",
                   stringsAsFactors=F,fileEncoding="UTF-8",
                   comment.char="",quote="",allowEscapes=F,
                   na.strings="NULL",fill=T)
  
  df <- df %>% 
    select(P01=P01ConceptID,
           Measurement=S06PrefLabel,
           MeasBasis=S02PrefLabel,
           MeasShort=S06AltLabel,
           Matrix=S26PrefLabel,
           CAS,
           Substance=S27PrefLabel,
           SubstanceShort=S27AltLabel,
           SpeciesMatrix=S25PrefLabel
    ) %>%
    separate(SpeciesMatrix,c("Species","Extra")," \\[",fill = "right") %>% 
    separate(Extra,c("Extra"),"\\]",fill = "right") %>%
    mutate(n=str_count(Extra, ":"))
  
  # the columns we want to keep
  cols<-c("P01","Measurement","MeasBasis","MeasShort","Matrix","CAS","Substance","SubstanceShort","Species")
  
  # and the following extra information to be extracted
  colsextra <- c("Sex","Subcomponent")
  
  n <- 1+max(df$n,na.rm=T)
  
  for(i in 1:n){
    col<-paste0("V",i)
    df <- df %>% mutate(nx=regexpr(":", Extra))
    df[,col]<-substr(df$Extra,1,df$nx-1)
    df$Extra<-substr(df$Extra,df$nx+1,999)
    
    df <- df %>% mutate(nx=regexpr(":", Extra))
    df <- df %>% mutate(nx=ifelse(nx>1,regexpr(" [^ ]*$", substr(Extra,1,nx)),999))
    
    col<-paste0("W",i)
    df[,col]<-substr(df$Extra,1,df$nx-1)
    df$Extra<-substr(df$Extra,df$nx+1,999)
  }
  
  colsv<-1:n
  colsv<-paste0("V",colsv)
  
  colsw<-1:n
  colsw<-paste0("W",colsw)
  
  dfv <- df[,c(cols,colsv)]
  dfw <- df[,c(cols,colsw)]
  
  dfv <- dfv %>% 
    gather(key="Key",value="Param",colsv) %>% 
    mutate(Key=as.numeric(substr(Key,2,99)))
  dfw <- dfw %>% 
    gather(key="Key",value="Value",colsw) %>% 
    mutate(Key=as.numeric(substr(Key,2,99)))
  
  df <- dfv %>% 
    left_join(dfw,by=c(cols,"Key")) %>%
    select(-Key)
  
  df <- df %>% 
    group_by_(.dots=c(cols,"Param","Value")) %>% 
    summarise() %>% 
    ungroup() %>%
    spread(key=Param,value=Value) %>%
    select_(.dots=c(cols,colsextra))
  
  return(df)
}

#Tests

#df2 <- dfx %>% filter(P01ConceptID=="ACMMCF03")
#df2 <- df %>% filter(Matrix=="biota")
# -----------------------------------------------------
#df %>% group_by(P01) %>% summarise(n=n()) %>% filter(n>1)


# S27PrefLabel - substance
# S27AltLabel - substance short
# CAS - CAS
# S02PrefLabel - dimensions of measurement
# S25PrefLabel - species
# S26PrefLabel - particle
# S03PrefLabel - extraction method
# S04PrefLabel - measurement method
# S05PrefLabel - calculation method
# S06PrefLabel - measurement
# S07PrefLabel - statistic
