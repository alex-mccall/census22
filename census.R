library(readxl)
library(leaflet)
library(sf)
library(tidyverse)
library(htmltools)
population_by_sex <- read_excel('census.xlsx', sheet = "Table 1", skip = 3)
population_by_5_year_age_groups <- read_excel('census.xlsx', sheet = "Table 2", skip = 3)
population_by_sex_and_5_year_age_groups <- read_excel('census.xlsx', sheet = "Table 3", skip = 3)
population_density <- read_excel('census.xlsx', sheet = "Table 4", skip = 3)
no_of_households_with_at_least_one_resident <- read_excel('census.xlsx', sheet = "Table 5", skip = 3)
geog_ref <- read.csv("geog_ref.csv")

colnames(geog_ref)[2] <- "Area code" 
colnames(geog_ref)[1] <- "Area name" 

d <- left_join(population_by_sex,geog_ref) %>% filter("Area name" != "Scotland")






my_shapefile <- st_read("Local_Authority_Boundaries/pub_las.shp")
#my_shapefile <- st_read("PC_Cut_23_1/PC_Cut_23_1.shp")

my_shapefile <- st_transform(my_shapefile, "+proj=longlat +datum=WGS84") 
my_shapefile <- left_join(my_shapefile, d,join_by("Council" == "Area code"))

bins <- c(0, 5000, 10000, 15000, 20000, 25000, 30000, 35000, Inf)
pal <- colorBin("YlOrRd", domain = my_shapefile$Population, bins = bins)

m <- leaflet() %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery") %>%
  addPolygons(data = my_shapefile,
              fillOpacity = 0.5,
              fillColor = ~pal(Females),
              color = "#BDBDBD",
              weight = 1,
              label = ~htmlEscape(paste(Council, Females)),
              highlightOptions = highlightOptions(color = "red", fillOpacity = 0.7))

m

m <- addLegend(m, "bottomright",
               title = "My Shapefile",
               pal = colorNumeric("Blues", my_shapefile$column),
               values = my_shapefile$column,
               opacity = 0.5)
m

