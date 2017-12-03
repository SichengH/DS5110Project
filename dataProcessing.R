library(data.table)
setwd("/Users/haosicheng/Desktop/5110ProjectData")


data<-fread("Combined_data.csv")


###################column clean##################
#clean zipcode
data$ZIPCODE<-as.character(data$ZIPCODE)
zipcode<-c("02108_","02109_","02110_","02111_","02113_","02114_","02115_","02116_","02118_","02119_","02120_","02121_","02122_","02124_","02125_","02126_","02127_","02128_","02129_","02130_","02131_","02132_","02134_","02135_","02136_","02199_","02210_","02215_","02467_")
data<-data%>%filter(ZIPCODE %in% zipcode)
data$ZIPCODE<-unlist(strsplit(data$ZIPCODE,"_"))

#LU land use
land<-c("A","CD","CD","CM","R1","R2","R3","R4","RC")
data<-data%>%filter(LU %in% land)

data<-data%>%filter(AV_TOTAL!=0)
data<-data%>%filter(YR_BUILT>1849)
data<-data%>%filter(YR_REMOD>1949 | YR_REMOD==0)
#Drop columns
data$CM_ID<-NULL
data$PTYPE<-NULL
data$OWN_OCC<-NULL
data$AV_LAND<-NULL
data$AV_BLDG<-NULL
data$OWNER<-NULL
data$OWNER_MAIL_ADDRESS<-NULL
data$OWNER_MAIL_CS<-NULL
data$OWNER_MAIL_ZIPCODE<-NULL

#AV_TOTAL
data1<-unite(data,"key",PID,Year,sep = "")
data1<-unite(data1,"key",key,ZIPCODE,sep = "_")
data1<-aggregate(AV_TOTAL~key,data1,mean)
data1<-separate(data1, key, into = c("PID", "Year","ZIPCODE"), sep = "_")
data.value.wide<-spread(data1,key = Year,value = AV_TOTAL)
#R_TOTAL_RMS
data2<-unite(data,"key",PID,Year,sep = "")
data2<-aggregate(R_TOTAL_RMS~key,data2,mean)
data2<-separate(data2, key, into = c("PID", "Year"), sep = "_")
data.totalRooms.wide<-spread(data2,key = Year,value = R_TOTAL_RMS)

#Latitude
data2<-unite(data,"key",PID,Year,sep = "")
data2<-aggregate(Latitude~key,data2,mean)
data2<-separate(data2, key, into = c("PID", "Year"), sep = "_")
data.latitude.wide<-spread(data2,key = Year,value = Latitude)

#Longitude
data2<-unite(data,"key",PID,Year,sep = "")
data2<-aggregate(Longitude~key,data2,mean)
data2<-separate(data2, key, into = c("PID", "Year"), sep = "_")
data.longitude.wide<-spread(data2,key = Year,value = Longitude)

remodel.data<-data%>%filter(YR_REMOD >2014)
uni_1<-function(list){
  temp<-unique(list)
  if(is.na(temp[1])&length(temp)==1){
    return(temp)
  }
  temp[is.na(temp)==FALSE]
  return(temp[1])
}

uni<-function(list){
  temp<-table(list)
  name<-names(temp)
  if(length(name)==1){
    return(name)
  } else {
    name<-name[name!=""]
    return(name[1])
  }
}

remo<-function(list){
  temp<-unique(list)
  if(length(temp)==1){
    return(temp)
  } else if(length(temp)==2&temp[1]==0){
    return(temp[2])
  } else {
    return(temp[1])
  }
}

remo2<-function(list){
  temp<-unique(list)
  if(length(temp)==1){
    return(0)
  } else if(length(temp)==2&temp[1]==0){
    return(0)
  } else {
    return(temp[2])
  }
}

ID<-unique(data$PID)
len<-length(ID)
PID<-rep(NA,len)
full_address<-rep(NA,len)
Latitude<-rep(NA,len)
Longitude<-rep(NA,len)
YR_BUILT<-rep(NA,len)
YR_REMOD<-rep(NA,len)
YR_REMOD2<-rep(NA,len)#
LIVING_AREA<-rep(NA,len)
NUM_FLOORS<-rep(NA,len)
STRUCTURE_CLASS<-rep(NA,len)
BDRMS<-rep(NA,len)
BATHS<-rep(NA,len)
HEAT<-rep(NA,len)
AC<-rep(NA,len)
BTH_STYLE<-rep(NA,len)
KIT_STYLE<-rep(NA,len)
INT_CND<-rep(NA,len)
INT_FIN<-rep(NA,len)
VIEW<-rep(NA,len)


#PID<-rep(0,len)
time<-Sys.time()
for(i in 1:len){
  tryCatch({
  t.data<-data%>%filter(PID==ID[i])
  if(nrow(t.data)<4){
    next
  }
  PID<-ID[i]
  full_address[i]<-uni(t.data$full_address)
  Latitude[i]<-uni(t.data$Latitude)
  Longitude[i]<-uni(t.data$Longitude)
  YR_BUILT[i]<-uni(t.data$YR_BUILT)
  YR_REMOD[i]<-remo(t.data$YR_REMOD)
  YR_REMOD2[i]<-remo2(t.data$YR_REMOD)
  LIVING_AREA[i]<-uni(t.data$LIVING_AREA)
  NUM_FLOORS[i]<-uni(t.data$NUM_FLOORS)
  STRUCTURE_CLASS[i]<-uni(t.data$STRUCTURE_CLASS)
  BDRMS[i]<-sum(as.numeric(uni(t.data$R_BDRMS)),as.numeric(uni(t.data$U_BDRMS)),na.rm = TRUE)
  BATHS[i]<-sum(as.numeric(uni(t.data$R_FULL_BTH)),as.numeric(uni(t.data$R_HALF_BTH)),as.numeric(uni(t.data$U_HALF_BTH)),as.numeric(uni(t.data$U_HALF_BTH)),na.rm = TRUE)
  HEAT[i]<-uni(c(t.data$U_HEAT_TYP,t.data$R_HEAT_TYP))
  AC[i]<-uni(c(t.data$U_AC,t.data$R_AC))
  BTH_STYLE[i]<-uni(c(t.data$U_BTH_STYLE,t.data$R_BTH_STYLE))
  KIT_STYLE[i]<-uni(c(t.data$U_KITCH_STYLE,t.data$R_KITCH_STYLE))
  INT_CND[i]<-uni(c(t.data$U_INT_CND,t.data$R_INT_CND))
  INT_FIN[i]<-uni(c(t.data$U_INT_FIN,t.data$R_INT_FIN))
  VIEW[i]<-uni(c(t.data$U_VIEW,t.data$R_VIEW))
  }, error=function(e){})
    
  
}
Sys.time()-time
data3<-data.frame(PID,full_address,Latitude,Longitude,YR_BUILT,YR_REMOD,YR_REMOD2,LIVING_AREA,NUM_FLOORS,STRUCTURE_CLASS,
                  BDRMS,BATHS,HEAT,AC,BTH_STYLE,KIT_STYLE,INT_CND,INT_FIN,VIEW)


data4<-na.omit(data3)
data4<-separate(data4,key = PID, into = c("PID","space"))
data5<-left_join(data3)



full.address<-unique(data$full_address)
for(i in 1:length(full.address)){
  t.data<-data%>%filter(full_address==full.address[i])
  
}

#and then doing unique feature 
#the same time with value



#combine apt at the end
