To find the greenest city in the USA I first needed a measure of 'green'. The most common measure is the Normalized Difference Vegetation Index, or NDVI. The NDVI is derived from aerial or satellite imagery where you have multiple wavelengths of light recorded. Here we need imagery with red, blue, green, and near infared.

The imagery I used was from the Landsat satellites, particularily Landsat 5 and 8. This earth observing satellite provides images of the Earth on a regular basis allowing for looking at images from 2013 and 2018.

I used Google Earth Engine to select and process the huge amount of images available to get the greenest pixels for the cities. To get a measure of 'greeness', I average all of the pixels that fell within the city boundaries so that each city gets a value for 2018.

The cities were those with a population of 100,000 or greater in the continental USA. The boundaries came from the US Census Bureau. One important note about citie sin the USA is that some of them are combined city-county governments. These combinations mean that the city boundary becomes that of the associated county, and encompasses more rural areas. This enlarged city area can inflate how 'green' the combined city-county is, so I have excluded those from the analysis.

After getting the data in Google Earth Engine I used R statistical software to analyse the data.

I also wanted to see 1) how the city green measure differed from 2013 (5 years earlier) and then 2) see where the city had lost or gained green vegetation. The 2013 measure came from Google Earth Engine, as did the cropped images of the cities. To avoid processing almost 300 cities I just looked at the top 5 and have their loss-gain images to look at.
