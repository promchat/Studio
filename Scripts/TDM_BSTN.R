rm(list = ls())

library(stplanr)
library(od)
library(data.table)
library(sf)
#install.packages("R.utils")
library(R.utils)
library(tidycensus)
library(tidyverse)
library(tmap)

#install.packages("od")
#vignette("od")
#install.packages("cyclestreets")

setwd("D:/Promit Chatterjee_UPenn_970401442/Studio")

data <- fread("Data/ma_od_main_JT00_2019.csv.gz")

data$w_geocode <- substr(data$w_geocode, 1, 11)
data$h_geocode <- substr(data$h_geocode, 1, 11)

data <- data %>% select(h_geocode, w_geocode, S000)
colnames(data) <- c("orig", "dest", "flow")

data <- data %>% mutate(County_d = substr(dest, 1, 5), County_o = substr(orig, 1, 5))
data <- data %>% filter(County_d == "25025" & County_o == "25025")

data <- data %>% select(orig, dest, flow)

write.csv(data, "SUFFOLK_OD_DATA.csv")
rm(list = ls())
gc()

data <- read.csv("SUFFOLK_OD_DATA.csv")
data <- data %>% select(orig, dest, flow)
data$orig <- as.character(data$orig)
data$dest <- as.character(data$dest)


SEPTA_BusRoute <- st_read("NTD/Data/Fall_2021_Routes/Fall_2021_Routes.shp")
SEPTA_SubRoute <- st_read("NTD/Data/SEPTA_-_Highspeed_Stations/SEPTA_-_Highspeed_Stations.shp")

#vars <- load_variables(year = 2019, dataset = "acs5")

vars <- c("B08006_001", "B08006_002","B08006_009", "B08006_010", "B08006_011", "B08006_012",
  "B08006_014", "B08006_015","B08006_016","B08006_017")
names <- c("TOTAL", "CAR", "BUS", "SUB", "COMM", "LR", "BIKE", "WALK", "OTHER", "WFH")

COMM <- get_acs(geography = "tract", variables = vars, year = 2018, output = "wide", state = 25,
                county = 025, geometry = T) # mode share

colnames(COMM) <- c("GEOID", "NAME", "TOTAL", "TOTAL_M", "CAR", "CAR_M", "BUS", "BUS_M", "SUB","SUB-M", "TRNST","TRNST-M", "LR","LR-M", "BIKE","BIKE-M", "WALK", "WALK-M", "OTHER","OTHER-M", "WFH", "WFH-M", "geometry")

COMM <- COMM %>% select("GEOID", "TOTAL","CAR", "BUS", "SUB", "TRNST", "LR", "BIKE", "WALK", "OTHER", "WFH", "geometry")

SFK_OD <- left_join(COMM, data, by = c("GEOID" = "orig"))

SFK_OD <- SFK_OD %>% select("GEOID", "dest","flow","TOTAL","CAR", "BUS", "SUB", "TRNST", "LR", "BIKE", "WALK", "OTHER", "geometry")

SFK_OD <- SFK_OD %>% mutate(TOTAL = CAR + BUS + SUB + TRNST + LR + BIKE + WALK + OTHER)

SFK_OD <- na.omit(SFK_OD)

SFK_OD$CAR <- round((SFK_OD$CAR / SFK_OD$TOTAL), 2)
SFK_OD$BUS <- round((SFK_OD$BUS / SFK_OD$TOTAL), 2)
SFK_OD$SUB <- round((SFK_OD$SUB / SFK_OD$TOTAL), 2)
SFK_OD$TRNST <- round((SFK_OD$TRNST / SFK_OD$TOTAL), 2)
SFK_OD$LR <- round((SFK_OD$LR / SFK_OD$TOTAL), 2)
SFK_OD$BIKE <- round((SFK_OD$BIKE / SFK_OD$TOTAL), 2)
SFK_OD$WALK <- round((SFK_OD$WALK / SFK_OD$TOTAL), 2)
SFK_OD$OTHER <- round((SFK_OD$OTHER / SFK_OD$TOTAL), 2)

CAR_OD <- SFK_OD 
CAR_OD$flow <- CAR_OD$flow*CAR_OD$CAR 

BIKE_OD <- SFK_OD
BIKE_OD$flow <- BIKE_OD$flow*BIKE_OD$BIKE

#denom <- PHL_OD %>% group_by(GEOID) %>% summarize(S000 = sum(S000, na.rm = T))

#d <- PHL_OD %>% mutate(denom = ifelse(GEOID == denom$GEOID, S000)) 

#PHL_OD <- st_join(PHL_OD, denom)

od_mat <- od_to_odmatrix(CAR_OD)
od_mat <- odmatrix_to_od(od_mat)


g <- SFK_OD %>% select(GEOID)
#g <- st_centroid(g)

#z <- od::od_to_sf(od_mat, g)

desire_lines <- od::od_to_sf(od_mat, g)

#desire_lines <- od2line(flow = od_mat, zones = g) # works

#w_dests <- dl %>% group_by(orig) %>% summarize(count = n()) %>% mutate(share = round(count / sum(count), 2))

CT <- c("25025030300", "25025070101", "25025070200", "25025010801", "25025010802", "25025010701", "25025010702")

#CT <- c("25025030300") #183

dl <- desire_lines %>% filter(dest %in% CT)

dl <- dl %>% filter(flow > 0.1)

#dl <- dl %>% filter(flow > 3)

#plot(desire_lines)

#od_coords(l=inter)

tmap_mode("view")

#tm_shape(w_dests) + 
 # tm_lines(col = "count", lwd = "count", scale = 8)

routes <- route(l = dl, route_fun = route_osrm, osrm.profile = "car") # OSRM

#install.packages("dodgr")

library(dodgr)
library(raster)
library(ggplot2)

# routes <- route_dodgr(l = dl)

COMM$CAR <- round((COMM$CAR / COMM$TOTAL), 2)

dest_points <- COMM %>% filter(GEOID %in% CT) %>% st_centroid()

all_points <- COMM %>% st_centroid()

tm_shape(COMM) +
  tm_polygons(col = "grey", alpha = 0.5) + 
  tm_shape(dest_points) + 
  tm_polygons(col = "green") + 
    tm_shape(routes) + 
    tm_lines(col = "flow", lwd = "flow", palette = "PRGn") +
  tm_shape(MBTA_routes) +
  tm_lines(col = "MBTA_VARIA")

tm_shape(COMM) +
  tm_polygons(col = "CAR") 

st_write(obj = routes, dsn = "car_routes_BostonDownTown.shp")  
st_write(obj = dest_points, dsn = "DestinationPoints_BostonDownTown.shp") 
st_write(obj = all_points, dsn = "AllPoints_BostonDownTown.shp")  



tmaptools::palette_explorer()
install.packages("shinyjs")
library(shinyjs)


library(rgdal)

plot(routes)
