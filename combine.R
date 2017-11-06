library(data.table)
library(tidyverse)
library(ggmap)


#west F
#Data read in 
file.list <- list.files(pattern='*.csv')
for (i in 1:length(file.list)) assign(file.list[i], read.csv(file.list[i]))

# Splitting the location columns into latitude and longitude
lat_lon <- function(x){
  for(i in 1:dim(x)[1]){
  y <- unlist(strsplit(as.character(x$Location[i]),"\\| "))
  y[1]<- gsub("\\(","",y[1])
  y[2]<- gsub("\\)","",y[2])
  x$Latitude <- as.numeric(y[1])
  x$Longitude <- as.numeric(y[2])
  return(x)
  }
}

`property-assessment-fy2014.csv` <- lat_lon(`property-assessment-fy2014.csv`)

`property-assessment-fy2015.csv` <- lat_lon(`property-assessment-fy2015.csv`)

#Changing some column names
colnames(`property-assessment-fy2014.csv`)[1] <- "PID"
colnames(`property-assessment-fy2014.csv`)[13] <- "OWNER_MAIL_ADDRESS"
colnames(`property-assessment-fy2014.csv`)[14] <- "OWNER_MAIL_CS"
colnames(`property-assessment-fy2014.csv`)[15] <- "OWNER_MAIL_ZIPCODE"
`property-assessment-fy2014.csv`$U_NUM_PARK <- NA


#identifying the rows by year
`property-assessment-fy2014.csv`$Year <- 2014
`property-assessment-fy2015.csv`$Year <- 2015


bind_df1 <- rbindlist(list(`property-assessment-fy2014.csv`,`property-assessment-fy2015.csv`), fill=TRUE)
bind_df1 <- within(bind_df1, rm(X,Location,full_address))

names(`property-assessment-fy2016.csv`)%in%names(bind_df1)

bind_df1%>%
  mutate(MAIL_ADDRESSEE = NA,
         R_BTH_STYLE = NA,
         R_BTH_STYLE2 = NA,
         R_BTH_STYLE3 = NA,
         R_KITCH_STYLE = NA,
         R_KITCH_STYLE2 = NA,
         R_KITCH_STYLE3 = NA,
         R_EXT_CND = NA,
         R_OVRALL_CND = NA,
         R_INT_CND = NA,
         R_INT_FIN = NA,
         S_EXT_CND = NA,
         U_BTH_STYLE = NA,
         U_BTH_STYLE2 = NA,
         U_BTH_STYLE3 = NA,
         U_KITCH_TYPE = NA,
         U_KITCH_STYLE = NA,
         U_INT_FIN = NA,
         U_INT_CND = NA,
         U_VIEW = NA)%>%
  unite(full_address,
        ST_NUM,
        ST_NAME,
        ST_NAME_SUF, 
        ZIPCODE, 
        sep = " ", 
        remove = FALSE)->bind_df1




`property-assessment-fy2016.csv`%>%
  mutate(LATITUDE = gsub("\\#N\\/A",NA,LATITUDE),
         LONGITUDE = gsub("\\#N\\/A",NA,LONGITUDE),
         Year = 2016)%>%
  rename(Latitude = LATITUDE,
         Longitude = LONGITUDE)%>%
  unite(full_address,
        ST_NUM,
        ST_NAME,
        ST_NAME_SUF, 
        ZIPCODE, 
        sep = " ", 
        remove = FALSE)-> `property-assessment-fy2016.csv`

`property-assessment-fy2016.csv`%>%
  filter(is.na(Latitude)|is.na(Longitude))%>%
  select(PID,Latitude,Longitude)%>%
  unique()->prop16

`property-assessment-fy2014.csv`%>%
  select(PID,Latitude,Longitude)%>%
  unique()->prop14

`property-assessment-fy2015.csv`%>%
  select(PID,Latitude,Longitude)%>%
  unique()->prop15

`property-assessment-fy2016.csv`%>%
  filter(!is.na(Latitude)|!is.na(Longitude))%>%
  select(PID,Latitude,Longitude)%>%
  unique()->q1

q1%>%
  left_join(prop16,by = "PID")%>%
  left_join(prop14,by = "PID")%>%
  left_join(prop15,by = "PID")%>%
  select(-c(Latitude.y,
            Longitude.y,
            Latitude.x.x,
            Longitude.x.x,
            Latitude.y.y,
            Longitude.y.y))->q2

`property-assessment-fy2016.csv`%>%
  filter(!is.na(Latitude)|!is.na(Longitude))%>%
  select(PID,Latitude,Longitude)%>%
  left_join(q2, by = "PID")->q3

`property-assessment-fy2017.csv`%>%
  left_join(q2,by ="PID")%>%
  rename(Latitude = Latitude.x,
         Longitude = Longitude.x)->`property-assessment-fy2017.csv`

#creating an address columns to download co-ordinates from the web
`property-assessment-fy2017.csv`%>%
  mutate(Year = 2017)%>%
  unite(full_address,
        ST_NUM,
        ST_NAME,
        ST_NAME_SUF, 
        ZIPCODE, 
        sep = " ", 
        remove = FALSE)-> `property-assessment-fy2017.csv`


#using the google api to download co-ordinates
# for(i in 1:nrow(`property-assessment-fy2017.csv`)){
#   result <- geocode(`property-assessment-fy2017.csv`$ADDress[i],
#                     output = "latlona",
#                     source = "google")
#   `property-assessment-fy2017.csv`$Longitude[i] <- as.numeric(result[1])
#   `property-assessment-fy2017.csv`$Latitude[i] <- as.numeric(result[2])
# }


bind_df2 <- rbindlist(list(`property-assessment-fy2016.csv`,`property-assessment-fy2017.csv`), fill=TRUE)

bind_df2%>%
  rename(MAIL_CS = MAIL.CS,
         OWNER_MAIL_ZIPCODE = MAIL_ZIPCODE)%>%
  select(-c(GIS_ID,ADDress))->bind_df2

final_df <- rbindlist(list(bind_df1,bind_df2), fill = T)


write.csv(final_df,"Combined_data.csv")

