# Mapa interactivo de distritos de la EOD 17 y los limites de alcaldías y municipios
# de la zona metropolitana del Valle de México 

# Cargar las librerías a utilizar
library(dplyr)
library(sp)
library(leaflet)
library(htmltools)

# Cargar capas
zmvm <- rgdal::readOGR("Data/zmvm", "zmvm")
distritos <- rgdal::readOGR("Data/distritos", "EOD2017_Distritos")

# Construimos un objeto para establecer coordenadas del centro la CDMX
lon <- -99.12766 
lat <- 19.42847
nombre <- "Zócalo"
zocalo <- data.frame(nombre, lon, lat)
#Eliminar insumos para el df zocalo
rm(lon, lat, nombre)

# paleta de colores para los distritos 
paleton <- colorFactor(palette = "Set3", 
                       domain = distritos@data$NOMBRE)

# Elaborar mapa base para luego agregar las capas
m_base2 <- leaflet(options = leafletOptions(
  minZoom = 10, dragging = TRUE)) %>% # Establecer un nivel de zoom fijo
  addProviderTiles("CartoDB") # Establecer mapa base
  setView(lng = zocalo$lon, lat = zocalo$lat, zoom = 9) %>% # Establecer punto central
  setMaxBounds(lng1 = zocalo$lon[1] + .6, # Establecer margenes del mapa 
               lat1 = zocalo$lat[1] + .65, 
               lng2 = zocalo$lon[1] - .6, 
               lat2 = zocalo$lat[1] - .6)

# Agregar capas al mapa base y crear objeto Dis_EOD2017  
Dis_EOD2017 <- m_base2 %>% 
  
  # Capa de los límites de las alcaldías 
  addPolygons(data = zmvm, weight = 3, fillOpacity = 0, 
              group = "Alcaldías y municipios") %>%
  
  # Capa de los límites de los distritos EOD 2017
  addPolygons(data = distritos, weight = 2, fillOpacity = 0.5,
              color = ~paleton(NOMBRE),
              popup = ~paste0("Distrito: ", DTO_EOD17, ", ", NOMBRE, "<br>","Mapa elaborado por ", 
                              "<a href='https://www.linkedin.com/in/hnlira/'
                              target ='_blank' >hnlira</a>", "<br>", "con base en ",
                              "<a href='http://giitral.iingen.unam.mx/Estudios/EOD-Hogares-01.html#distritos'
                              target ='_blank' >IINGEN - UNAM</a>")  %>% 
                lapply(htmltools::HTML),
              labelOptions = labelOptions(textsize = "13px"),
              highligh = highlightOptions(weight = 5,
                                          color = "red", 
                                          bringToFront = FALSE),
              group = "Distritos EOD17") %>%
  
  # Agregar capa de control 
  addLayersControl(overlayGroups = c("Alcaldías y municipios", "Distritos EOD17")) 

# Imprimir mapa
Dis_EOD2017

# Esxportar mapa
htmlwidgets::saveWidget(Dis_EOD2017, file = "Export/disEOD2017.html") 

