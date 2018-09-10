

getheader<-function(idx,strlst){
  str<-strlst[[idx]]
  if(substr(str,1,16) %in% c("//<DataVariable>","//<MetaVariable>")){
    vartype<-substr(str,4,15)
    str<-substr(str,17,nchar(str)-16)
    str<-strsplit(str,"\" " )
    str<-data.frame(str,stringsAsFactors=F)
    names(str)<-c("str")
    str <- str %>% separate(str,c("param","value"),"=\"") 
    
    comment<-str %>% filter(param=="comment")
    comment<-comment[1,2]
    if(!is.na(comment)){
      comment<-strsplit(comment," SDN:")
      comment<-data.frame(comment,stringsAsFactors=F)
      names(comment)<-c("comment")
      comment <- comment %>% separate(comment,c("param","value"),"::",fill = "right") %>%
        filter(!is.na(value))    
      str<-str %>% bind_rows(comment)
    }
    param<-"Type"
    value<-vartype
    df<-data.frame(param,value,stringsAsFactors=F)
    str<-str %>% 
      bind_rows(df) %>% 
      mutate(i=idx)
  }else{
    str<-NULL
  }
  return(str)
  
}

getrows<-function(idx,strlst){
  str<-strlst[[idx]]
  if(substr(str,1,2) == "//"){
    return(idx)
  }else{
    return(NA)
  }
}

convert<-function(EMODNETfile){ 
  
  
  dat <- readLines(con<-file(EMODNETfile, encoding = "utf-8"))
  close(con)
  
  # Get header info from the data files
  dflist<-lapply(seq_along(dat),function(x) getheader(x,dat))
  dflist<-dflist[lapply(dflist, length) > 0]
  dfhead<-do.call(rbind, dflist) %>% spread(key="param",value="value")
  
  dfparams<-dfhead %>% filter(Type=="DataVariable") %>% select(label,P01,P06)
  
  # Get the number of lines which are commented out
  dflist<-sapply(seq_along(dat),function(x) getrows(x,dat))
  nskip<-max(dflist,na.rm=T)
  
  # Get column names from the first line in the data file which is not commented out
  dfcols <- read.table(EMODNETfile,sep="\t",header=F,stringsAsFactors=F,fileEncoding="UTF-8",
                       comment.char="",allowEscapes=F,na.strings="NULL",fill=T,skip=nskip) %>% head(1) %>% 
    gather(key="col")
  
  # Get data
  df <- read.table(EMODNETfile,sep="\t",header=F,stringsAsFactors=F,fileEncoding="UTF-8",
                   comment.char="",allowEscapes=F,na.strings="NULL",fill=T,skip=nskip+1)
  
  # Get column names (V1 ... Vn) for the parameters taken from the headers
  dfcolvalue <- dfparams %>% inner_join(dfcols,by=c("label"="value"))
  
  # Get column names (V1 ... Vn) for the quality code for each parameter (one column to the right of the value column)
  dfcolqual <- dfcolvalue %>% mutate(col=paste0("V",as.numeric(substr(col,2,9))+1))
  
  colmin<-as.numeric(substr(dfcolvalue$col[1],2,99))
  colmax<-as.numeric(substr(dfcolqual$col[nrow(dfcolqual)],2,99))
  
  df <- df %>% gather(key="col",value="value",colmin:colmax)
  
  # selecting the first 9 columns of data
  dfval <- df %>% 
    inner_join(dfcolvalue,by="col") %>% 
    select(V1:V9,value,label,P01,P06,-col)
  dfqual <- df %>% 
    inner_join(dfcolqual,by="col") %>%
    rename(quality=value) %>% 
    select(V1:V9,label,quality,P01,P06,-col)
  
  df <- dfval %>% 
    left_join(dfqual)
  
  names(df)[1:9]<-dfcols$value[1:9]
  return(df)
}
