setwd("D:/Promit Chatterjee_UPenn_970401442/Studio/Data")

rm(list = ls())

library(sf)
library(tidyverse)
library(tmap)

MBTA_routes <- st_read("mbtabus/MBTABUSROUTES_ARC.shp")

SL_routes <- st_read("mbtabus/MBTA_ARC.shp")

Routes <- c("1", "15", "22", "23", "28", "32", "39", "57", "66", "71", "73", "77", "93", "111", "116", "117", "SL4", "SL5")

BusPt_Y <- c("1", "22", "39", "57", "66", "93", "111", "SL4", "SL5")

Boston_Y <- c("1", "15", "22", "23", "28", "32", "39", "57", "66", "93", "111", "116", "117", "SL4", "SL5")

## In and out of Boston. Bus priority treatment

## 

## 116/117 

## 32 

### filter for the Boston Routes only

## remove 47 and 70 and 16


SL_routes <- SL_routes %>% filter(ROUTE %in% Routes)

SL_routes <- SL_routes %>% select(LINE, ROUTE, SHAPE_LEN, geometry)

key_routes <- filter(MBTA_routes, CTPS_ROUTE%in% Routes)
key_routes <- key_routes %>% select(CTPS_ROUTE, SHAPE_LEN, geometry)
key_routes <- key_routes %>% mutate(LINE = "YELLOW") %>% select(LINE, CTPS_ROUTE, SHAPE_LEN, geometry)
colnames(key_routes)[2] <- "ROUTE" 

key_routes <- key_routes %>% mutate(inBounds = ifelse(ROUTE %in% Boston_Y, TRUE, FALSE),
                                    BusPriority = ifelse(ROUTE %in% BusPt_Y, TRUE, FALSE))

SL_routes <- SL_routes %>% mutate(inBounds = ifelse(ROUTE %in% Boston_Y, TRUE, FALSE),
                                    BusPriority = ifelse(ROUTE %in% BusPt_Y, TRUE, FALSE))

tmap_mode("view")


  tm_shape(key_routes) + 
  tm_lines(col="blue") + 
  tm_shape(SL_routes) + 
  tm_lines(col = "orange")



write.csv(SL_routes, "Silver Line Routes.csv")
write.csv(key_routes, "Yellow Line Routes.csv")

st_write(SL_routes, "Silver Line Routes.shp")
st_write(key_routes, "Yellow Line Route.shp")


