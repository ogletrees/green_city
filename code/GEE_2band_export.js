// get 2018 & 2013 greenest pixel, make 2 band image, export to drive

var cname = "Atlanta_GA"

var city = ee.FeatureCollection("users/ssogletree/cities") // all of the cities
var fc = city.filter(ee.Filter.eq('city_st', cname)) // just one to test
var city_simp = fc.select(["city_st"]) // drop all cols but...
//////////////////////////////////////////////////////////////
// the NDVI function //
var addNDVI = function(image) {
  var ndvi = image.normalizedDifference(['B5', 'B4']).rename('NDVI');
  return image.addBands(ndvi);
};

// Get elevation to mask 0
var elevation = ee.Image("USGS/SRTMGL1_003") // elevation data


//////////////////////////////////////////////////////////////
// 2018 imagery
var ls18 = ee.ImageCollection('LANDSAT/LC08/C01/T1_RT_TOA')
  .filterDate('2018-01-01', '2018-12-01');


// map over collection
var NDVI18 = ls18.map(addNDVI);

// Make a "greenest" pixel composite.
var green18 = NDVI18.qualityMosaic('NDVI');
// print(greenest);

// Get just the NDVI value band
var NDVI2 = green18.select('NDVI').rename("ndvi18")

// mask out water
// apply mask    
var NDVIc18 = NDVI2.mask(elevation.neq(0))
// clip to city boundary
var NDVIlate = NDVIc18.clip(city_simp)

//////////////////////////////////////////////////////////////
// 2013 imagery
var ls13 = ee.ImageCollection('LANDSAT/LC08/C01/T1_RT_TOA')
  .filterDate('2013-02-01', '2013-12-01');


// map over collection
var NDVI13 = ls13.map(addNDVI);

// Make a "greenest" pixel composite.
var green13 = NDVI13.qualityMosaic('NDVI');
// print(greenest);

// Get just the NDVI value band
var NDVI1 = green13.select('NDVI').rename("ndvi13")

// mask out water
// apply mask    
var NDVIc13 = NDVI1.mask(elevation.neq(0))
// clip to city boundary
var NDVIearly = NDVIc13.clip(city_simp)
//////////////////////////////////////////////////////////////
var city_green = NDVIearly.addBands(NDVIlate)
Map.centerObject(city_simp, 10)
Map.addLayer(city_green)

// Export the image, specifying scale and region.
Export.image.toDrive({
  image: city_green,
  description: 'ndvi_city_' + cname,
  folder: 'project_green_cities',
  scale: 30,
  region: city_simp.geometry().bounds(),
  crs: 4326
});