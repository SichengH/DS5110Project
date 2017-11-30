library(tidyverse)
library(foreign)
library(rgdal)

#data: https://www.zillow.com/howto/api/neighborhood-boundaries.htm

dbf <- read.dbf("ZillowNeighborhoods-MA.dbf")
shape <- readOGR(dsn = "ZillowNeighborhoods-MA.shp")

s1 <- subset(shape, City =="Boston")
s2 <- fortify(s1)
write.csv(s2,"coordinates.csv") 
