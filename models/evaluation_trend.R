library(readr)
library(tidyverse)
library(reshape2)
load("~/Documents/Northeastern_University/DS5110_Data_Processing_Data_Management/DS5110Project/m_data/data.coord.rda")
points_new <- read_csv("m_data/points_new.csv", 
                       col_names = FALSE)

colnames(points_new) <- c("PID","LON","LAT","RegionID","RegionName")

points_new%>% 
  group_by(PID, RegionName)%>% 
  count() -> points_new2

check_points_new2 <- points_new2%>% 
  group_by(PID)%>% 
  summarize(upid = n())%>% 
  group_by(upid)%>%
  summarize(pid_count = n())


kicked_PID<- points_new2 %>% group_by(PID) %>%
  summarize(upid = n(),
            regions = paste(RegionName,
                            collapse = ", ")) %>%
  filter(upid > 1)

write.csv(kicked_PID,"kicked_PID.csv")

notkicked_PID <- points_new2 %>% group_by(PID) %>%
  summarize(upid = n(),
            regions = paste(RegionName,
                            collapse = ", ")) %>%
  filter(upid == 1)

write.csv(notkicked_PID,"notKicked_PID.csv")

pid.remove <- kicked_PID$PID

data.coord%>%
  filter(!PID %in% pid.remove)%>%
  left_join(y=notkicked_PID,by = "PID")%>%
  filter(!is.na(regions))->model.data
write.csv(model.data,"model_data.csv")

model.data%>%
  group_by(regions)%>%
  transmute(`14-15` = (X2015-X2014),
         `15-16` = (X2016-X2015),
         `16-17` = (X2017-X2016))%>%
  group_by(regions)%>%
  summarise_all(mean)-> mean_growth


mean_growth%>%
  melt()%>%
  ggplot(aes(x = regions,
             y = value))+
  labs(x = "Increase",
       y = "Neighborhoods",
       color = "Increase in Evaluations",
       title = "Assemeent Value Increase per year")+
  geom_point(aes(color = variable),size = 4)+
  coord_flip()


