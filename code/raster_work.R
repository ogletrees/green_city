library(raster)
library(rasterVis)
library(ggplot2)
r <- stack("C:/Users/admin/Downloads/ndvi_city_Atlanta_GA.tif")
r
plot(r)
# from GEE script, band 1 = 2013, band 2 = 2018
inMemory(r)
hist(r)
r@layers
names(r) <- c("ndvi2013", "ndvi2018")
plot(r[[2]])
# http://www.spatialreference.org
newproj <- "+proj=utm +zone=16 +ellps=clrk66 +units=m +no_defs"
pr1 <- projectRaster(r, crs=newproj)
plot(pr1[[2]])
pr1

# could change to a UTM projection or leave as WGS


grndiff <- overlay(pr1[[1]],
                   pr1[[2]],
                      fun=function(r1, r2){return(r2-r1)})
plot(grndiff)
grndiff
par(mfrow=c(1,1))
plot(density(grndiff))
base::mean(grndiff@data@values, na.rm=T)
levelplot(grndiff)

colr <- colorRampPalette(brewer.pal(11, 'RdYlBu'))
levelplot(grndiff, 
          margin=FALSE,
          xlab = NA)

gplot(grndiff) + geom_tile(aes(fill = value)) +
  scale_fill_gradient(low = 'red', high = 'green',na.value = NA) +
  ggtitle("Atlanta Change")

gplot(pr1[[2]]) + geom_tile(aes(fill = value)) +
  scale_fill_gradient(low = 'black', high = 'forestgreen',na.value = NA) +
  ggtitle("Atlanta 2018")

# mapview::mapview(grndiff)
mapview::mapview(r)
# count pixels
pix <- grndiff@data@values
str(pix)
pix <- pix[!is.na(pix)]
# gain
gup <- length(pix[pix > 0.2])
gdown <- length(pix[pix < -0.2])
chng1 <- (gup/ length(pix))*100
chng2 <- (gdown/ length(pix))*100

d <- as.data.frame(grndiff@data@values)
names(d) <- "values"
ggplot(d, aes(values)) + geom_density()
ggplot(d, aes(values)) + geom_histogram(bins = 50)
base::mean(d$values, na.rm=T)
