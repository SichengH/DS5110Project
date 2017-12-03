library(tidyverse)
library(foreign)
library(rgdal)

#data: https://www.zillow.com/howto/api/neighborhood-boundaries.htm

dbf <- read.dbf("~/Downloads/zillow-neighborhoods/ZillowNeighborhoods-MA.dbf")


fpath <- "/home/tbonza/Downloads/zillow-neighborhoods/ZillowNeighborhoods-MA.shp"
shape <- readOGR(dsn = fpath)

s1 <- subset(shape, City =="Boston")
s2 <- fortify(s1)


write.csv(s2,"coordinates.csv") 



#
dbf[dbf$City == "Boston",]


shape$RegionID[shape$City == "Boston"]


shape@polygons$ID %in% shape$RegionID[shape$City == "Boston"]


id_finder <- function(shape){
    ids <- c()
    for (i in 1:length(shape@polygons)){
        ids <- c(ids, shape@polygons[i][[1]]@ID)
    }
    return(ids)
}

