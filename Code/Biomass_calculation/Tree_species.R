# this section has to be run only the first time
# install.packages("remotes")
# remotes::install_github("ropensci/allodb")
#-------------------------------------------------------------------------------
# libraries used
library(effects)
library(plotrix)
library(gridExtra)
library(kgc)
library(dplyr)
library(readxl)
library(allodb)
library(ggplot2)
library(maps)
library(scales)
library(knitr)
library(kableExtra)
library(osmdata)
library(leaflet)
library(leaflet.extras)
library(maps)

#-------------------------------------------------------------------------------
# CHOOSE YOUR SITE LOCATION

#insert here the name of the nearest city
data(world.cities)

# find the coordinates
city_read <- readline(prompt="Enter the nearest city name: ")
city <- world.cities[world.cities$name == city_read, ]


# map with site
leaflet() %>%
  addTiles() %>%
  setView(lng = city$long, lat = city$lat, zoom = 11) %>%
  addMarkers(lng = city$long, lat = city$lat) %>%
  addMiniMap(width = 150, height = 150)

#-------------------------------------------------------------------------------
# UPLOADING OF THE TREE SPECIES IDENTIFICATION RESULTS

# insert here your file with the tree species
message("Choose an excel file with tree species")
file_path <- file.choose()

# read the Excel file
tryCatch({
  tab_species_1 <- readxl::read_excel(file_path)
  print("File read correctly!")
  print(head(tab_species_1))  # print the first lines of the database
}, error = function(e) {
  print(paste("Error during the reading of the Excel file:", e))
})

#dividing the latin names in genus and species
genus <- vector("character", length = nrow(tab_species_1)) 
species <- vector("character", length = nrow(tab_species_1))  

for (i in 1:nrow(tab_species_1)) {
  species_value <- tab_species_1$species[i]
  parts <- unlist(strsplit(species_value, " "))
  genus[i] <- parts[1]  
  species[i] <- parts[2]  
}

tab_species <- cbind(genus,species)
tab_species <- data.frame(tab_species)

#---------------------------------------------------------------------------------------------------------------------------------------
# DATA

# area covered by the point cloud
# given as result from Cloudcompare with 3DFin
area <- 1695 #[m^2]

# table of conversion for units
conv_dbh <- read.csv2("conv_dbh.csv")

# choose the diameters file from Cloudcompare with 3DFin
message("Choose a csv file with the tree dbh")
file_path <- file.choose()

# read the csv file
tryCatch({
  tab_dbh <- read.csv2(file_path)
  print("File read correclty!")
  print(head(tab_dbh))  # print the first lines of the database
}, error = function(e) {
  print(paste("Error during the reading of the Excel file:", e))
})

# rearrangement of the dataset
result <- tab_dbh
result$X <- as.numeric(result$X)
result$Y <- as.numeric(result$Y)
result$GEN <- tab_species$genus[1]
result$SPEC <- tab_species$species[1]

dbh_values <- as.numeric(result$DBH) 

# choose the unit of dbh
a <- readline(prompt="Enter the unit of dbh (m, cm, mm, inch): ")
a <- which(conv_dbh$X == a)

# based on the unit that we have, we should convert it to cm because it is requested by get_biomass function
b <- which(colnames(conv_dbh) == 'cm')
dbh_values <- dbh_values*as.numeric(conv_dbh[a,b]) # from meters to centimeters


#---------------------------------------------------------------------------------------------------------------------------------------
# BIOMASS ESTIMATION

agb <- get_biomass(dbh_values, 
                       result$GEN, 
                       coords = c(city$lat,city$long), 
                       result$SPEC, 
                       wna = 0.1, w95 = 500, nres = 10000)
result$AGB <- agb

# total biomass of the forest
total_biomass <- sum(agb)

# biomass per area [m^2]
biomass_perm2 <- total_biomass/area

#-------------------------------------------------------------------------------
# MAP OF THE AREA

# coordinates obtained manually through google maps
polygon_coords <- list(
  cbind(c(7.664122, 7.664257, 7.665523, 7.665444), c(45.063845, 45.063991, 45.063514, 45.063389))
)
coord <- c(45.063845, 7.664122)

# popup for the biomass marker on the map 
biomass_tot <- round(sum(agb))
biomass_tot <- as.character(biomass_tot)
biomass_tot <- c("The total biomass is",biomass_tot, "[Kg]")
biomass_tot <- paste(biomass_tot, collapse = " ")

# popup for the number of trees on the map
num_trees <- length(agb)
num_trees <- c("The number of trees is:",num_trees)
num_trees <- paste(num_trees, collapse = " ")

# popup content
popup_content <- paste0(
  "<div style='color: blue; background-color: yellow; padding: 5px; border-radius: 5px;'>",
  biomass_tot,
  "</div>"
)


# visualizing the biomass
leaflet() %>%
  addTiles() %>%
  setView(lng = coord[2], lat = coord[1], zoom = 25) %>%
  addMarkers(lng = coord[2], lat = coord[1], popup = popup_content) %>%
  addPolygons(
    lng = polygon_coords[[1]][, 1],
    lat = polygon_coords[[1]][, 2],
    color = "blue",
    weight = 2,
    fillColor = "lightblue",
    fillOpacity = 0.5,
    highlightOptions = highlightOptions(
      color = "red",
      weight = 3,
      bringToFront = TRUE
    ),
    popup = num_trees
  ) %>%
  addMiniMap(width = 150, height = 150)


#---------------------------------------------------------------------------------------------------------------------------------------
# BAR PLOTTING

ggplot(data = result, aes(x = factor(DBH), y = AGB, fill = SPEC)) +
  geom_bar(stat = "identity", color = "black") +
  scale_fill_discrete() + 
  labs(title = "Biomass calculation",
       x = "Tree diameter [cm]",
       y = "Biomass [Kg]") +
  theme(axis.text.x = element_text(angle = 90, hjust = 1, size = 8))



#---------------------------------------------------------------------------------------------------------------------------------------
# STACK BAR PLOTTING
category <- c('trees')

ggplot(result, aes(fill=T, y=AGB, x=category)) + 
  geom_bar(position="stack", stat="identity", color="black") +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey"),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  geom_text(aes(label=T), position=position_stack(vjust=0.5), size=3) +
  theme(legend.position="none") + 
  labs(x="Category", y="AGB [kg]", fill="Trees", title="Total Biomass of the forest")

#---------------------------------------------------------------------------------------------------------------------------------------
# BOX PLOTTING

boxplot(result$AGB, 
        main = "Average biomass estimation",
        xlab = "Trees", ylab = "Biomass [kg]",
        col = c("#83A655"), border = "black", notch = FALSE, xaxt = "n")

#---------------------------------------------------------------------------------------------------------------------------------------
# SCATTER PLOT

p <- ggplot(result, aes(x=X, y=Y)) +
  geom_point(aes(size = AGB), colour = c('#83A655')) +
  #scale_colour_gradientn(colours = c('#83A655')) +
  #theme(plot.background = element_rect(fill = "#F6E9D3")) +
  theme(panel.background = element_rect(fill = "white"),
        panel.grid.major = element_line(colour = "grey"),
        panel.grid.minor = element_line(colour = "grey"),
        plot.title = element_text(face = "bold", hjust = 0.5)) +
  #theme(text = element_text(family = "Montserrat"))
  geom_text(aes(label = T), vjust = 1.5, color = "black") +
  scale_size_continuous(name = "AGB [kg]") +
  scale_x_continuous(labels = number_format(accuracy = 1)) +
  scale_y_continuous(labels = number_format(accuracy = 1)) +
  ggtitle("Spatial distribution of biomass") +
  xlab("X coordinate") +
  ylab("Y coordinate")
  
print(p)

#---------------------------------------------------------------------------------------------------------------------------------------
# TABLE

table_res <- data.frame( number_trees = length(dbh_values), 
                        area, 
                        total_biomass, 
                        biomass_perm2)

colnames(table_res) <- rep("&nbsp;", ncol(table_res))

# Generate the table
kable(table_res, "html", escape = F, caption = "Results") %>%
  kable_styling("striped", bootstrap_options = c("striped", "hover"), 
                position = "left") %>%
  add_header_above(c("Number of trees" = 1,"Area [m^2]" = 1,"Total Biomass [kg]" = 1,"Biomass Density [kg/m^2]" = 1)) %>% 
  row_spec(0, extra_css = "border-color: #83A655;")
