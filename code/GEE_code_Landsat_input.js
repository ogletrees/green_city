// Getting greenness for cities with Landsat imagery

var table = ee.FeatureCollection("users/ssogletree/archive/cities_conus")
// var city = table.filterMetadata("city_st", "equals", "San Francisco_CA")
var cities = table.limit(10).select("city_st")
Map.addLayer(cities)
//----------------------------------------------------------------------
//----------------------------------------------------------------------
// Landsat data for 1998
var LS5 = ee.ImageCollection("LANDSAT/LT05/C01/T1_TOA")
  .filterDate("1998-01-01", "1998-12-31")
  
// Greenest Pixel Composite
function addNDVI(input) {
  var ndvi = input.normalizedDifference(['B4', 'B3']).rename("ndvi")
  return input.addBands(ndvi)
}

var ndviCollection = LS5.map(addNDVI)
var composite = ndviCollection.qualityMosaic('ndvi')
var NDVI = composite.select('ndvi')

// Map.addLayer(NDVI, {max:1, bands:["ndvi"], palette: ['gray','yellow','green']}, 'NDVIfull')

//////////////////////////////////////////////////////////////////////

// Get elevation to mask 0
var elevation = ee.Image("USGS/SRTMGL1_003") // elevation data

// apply mask    
var wmask = NDVI.mask(elevation.neq(0))
var NDVI2 = wmask.clipToCollection(cities)

Map.addLayer(NDVI2, {max:1, bands:["ndvi"], palette: ['gray','yellow','green']}, 'NDVI')

// //--------------------------------------------------------------
// // Map over feature collection, get the mean & sd NDVI
var meanval = NDVI2.reduceRegions({
  collection: cities,
  reducer: ee.Reducer.mean().setOutputs(['ndvi_mean98']).combine({
		reducer2: ee.Reducer.stdDev().setOutputs(['ndvi_sd98']),
    sharedInputs: true
  }),
  scale: 30 // 30 meters for Landsat
});

// print(meanval.toList(6))


// drop .geo
var ndviOut = meanval.select(['.*'], null, false);

// select cols to keep
// var ndviOut2 = ndviOut.select(["city_st", "ndvi_mean98", "ndvi_sd98"]);

// export to google drive
 Export.table.toDrive({
  collection: ndviOut, 
  description: 'GreenCity_test_20181130', 
  folder: 'RemoteSensingWork', 
//fileNamePrefix: , 
  fileFormat: 'CSV'
  }); 
