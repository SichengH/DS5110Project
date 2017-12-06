model.data <- read_csv("models/model_data.csv",
                       col_types = cols(Latitude = col_skip(),
                                        Longitude = col_skip(), STRUCTURE_CLASS = col_skip(),
                                        X1 = col_skip(), upid = col_skip()))

model.data%>%
  group_by(regions)%>%
  transmute(price_per_sqft14 = X2014/LIVING_AREA,
            price_per_sqft15 = X2015/LIVING_AREA,
            price_per_sqft16 = X2016/LIVING_AREA,
            price_per_sqft17 = X2017/LIVING_AREA)%>%
  na.omit()%>%
  group_by(regions)%>%
  summarise_all(mean)-> rise_per_sqft

rise_per_sqft%>%
  melt()%>%
  ggplot(aes(x = reorder(regions,value),
             y = value,
             fill = variable))+
  geom_bar(stat = "identity",
           position = position_dodge(width =0.8))+
  coord_flip()+
  labs(x = "Neighborhoods",
       y = "Value per sqft in $",
       fill = "",
       title = "Assesment value per sqft per year")


x <- as.matrix(rise_per_sqft[2:4])
y <- rise_per_sqft$price_per_sqft17
lm_fit <- lm(y~x)
summary(lm_fit)
sqrt(mean(resid(lm_fit)^2))
mean(abs(resid(lm_fit)))
rise_per_sqft$projectedfor2018 <- predict(lm_fit, newdata = rise_per_sqft[3:5])

write.csv(rise_per_sqft,"ProjectedRiseInSqft")
