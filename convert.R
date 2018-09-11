

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

convert<-function(EMODNETfile,infocols=c(1,2,3,4,5,6,7,8,9),timeseries=F,dropmissing=F){ 
  infocolsid<-infocols
  infocols<-paste0("V",infocols)
  
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
  dfcols <- read.table(EMODNETfile,sep="\t",header=F,stringsAsFactors=F,
                       fileEncoding="UTF-8",comment.char="",
                       allowEscapes=F,na.strings="NULL",
                       fill=T,skip=nskip) %>% 
    head(1) %>% 
    gather(key="col")
  
  # Get data
  df <- read.table(EMODNETfile,sep="\t",header=F,stringsAsFactors=F,fileEncoding="UTF-8",
                   comment.char="",allowEscapes=F,na.strings="NULL",fill=T,skip=nskip+1,quote="")
  
  # Get column names (V1 ... Vn) for the parameters taken from the headers
  dfcolvalue <- dfparams %>% inner_join(dfcols,by=c("label"="value"))
  
  # Get column names (V1 ... Vn) for the quality code for each parameter (one column to the right of the value column)
  dfcolqual <- dfcolvalue %>% mutate(col=paste0("V",as.numeric(substr(col,2,9))+1))
  
  colmin<-as.numeric(substr(dfcolvalue$col[1],2,99))
  colmax<-as.numeric(substr(dfcolqual$col[nrow(dfcolqual)],2,99))
  
  if(timeseries==T){
    colt1<-dfcols[dfcols$value=="yyyy-mm-ddThh:mm:ss.sss","col"]
    colt2<-dfcols[dfcols$value=="time_ISO8601","col"]
    for(i in 2:nrow(df)){
      df[i,colt1]<-ifelse(df[i,colt1]=="",df[i,colt2],df[i,colt1])
      for(v in infocols){
        if(v!=colt1){
          df[i,v]<-ifelse(is.na(df[i,v]),
                          df[i-1,v],
                          ifelse(df[i,v]=="",df[i-1,v],df[i,v]))
        }
      }
    }
  }
  
  df <- df %>% gather(key="col",value="value",colmin:colmax)
  
  dfval <- df %>% 
    inner_join(dfcolvalue,by="col") %>% 
    select_(.dots=c(infocols,"value","label","P01","P06")) 
  dfqual <- df %>% 
    inner_join(dfcolqual,by="col") %>%
    rename(quality=value) %>% 
    select_(.dots=c(infocols,"quality","label","P01","P06")) 
  
  
  df <- dfval %>% 
    left_join(dfqual,by=c(infocols,"label","P01","P06"))
  
  n<-length(infocols)
  names(df)[1:n]<-dfcols$value[infocolsid]
  
  if(dropmissing==T){
    df<-df %>% filter(!is.na(value))
  }
  return(df)
}
