library(tidyverse)
library(ggplot2)
library(sf)
library(tmap)
library(tidycensus)

load("D:/Promit Chatterjee_UPenn_970401442/CPLN 550/NTD DATA PROJECT/NTD Process/TS2.1TimeSeriesOpExpSvcModeTOS 2017.Rda")

setwd("D:/Promit Chatterjee_UPenn_970401442/Studio")

Boston <- NTD.ts %>% filter(City == "Boston")

BostonBus <- Boston %>% filter(Mode == "MB" & PMT > 0)

BostonBus_DO <- Boston %>% filter(Mode == "MB" & PMT > 0 & Service == "DO")

BostonBus_PT <- Boston %>% filter(Mode == "MB" & PMT > 0 & Service == "PT")

par(mfrow=c(1,2))

plot(BostonBus_PT$PMT, col = "red")

lines(BostonBus_PT$PMT, col = "red")

plot(BostonBus_DO$PMT, col = "blue")

lines(BostonBus_DO$PMT, col = "blue")

p <- ggplot(data = BostonBus, aes(x = Year, y = PMT, col = Service, size = Service)) + geom_line() + 
      scale_x_continuous(name = "Year", labels = c(1990:2017), breaks = c(1990:2017)) + 
      geom_vline(xintercept = 2008, linetype = "longdash") + 
      geom_hline(yintercept = 275000000, linetype = "longdash")

p + labs(title = "Bus Ridership Trends in Boston 1990-2017", subtitle = "(Source: NTD 2017)")
  

MBTA_routes <- st_read(dsn ="Data/mbtabus/MBTABUSROUTES_ARC.shp")
MBTA_PT_STOPS <- st_read("Data/mbtabus/MBTABUSSTOPS_PT.shp")

tmap_mode("view")

tm_shape(MBTA_PT_STOPS) +
  tm_dots(col = "orange") + 
  tm_shape(MBTA_routes) + 
  tm_lines(col = "green")

vars <- load_variables(year = 2019, dataset = "acs5")

BostonDem <- get_acs(geography = "county", variables = c("B01001H_001", "B01001I_001", "B01001H_001"), state = 25, county = 025,
                     year = 2019, output = "wide", geometry = T)

unique(BostonBus_PT$Year)

