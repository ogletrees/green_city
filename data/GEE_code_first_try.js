// Getting NDVI for city bounds

var table = ee.FeatureCollection("users/ssogletree/archive/cities_conus")
// get one city to test
var city = table.filterMetadata("city_st", "equals", "San Francisco_CA")

Map.addLayer(city)
//----------------------------------------------------------------------
//----------------------------------------------------------------------
// Sentinel data
// var Sen = ee.ImageCollection("COPERNICUS/S2")
//   .filterDate('2017-01-01', '2017-11-01')

// // Greenest Pixel Composite
// function addNDVI(input) {
//   var ndvi = input.normalizedDifference(['B8', 'B4']).rename("ndvi")
//   return input.addBands(ndvi)
// }

// var ndviCollection = Sen.map(addNDVI)
// var composite = ndviCollection.qualityMosaic('ndvi')
// var NDVI = composite.select('ndvi')


// // Map.addLayer(NDVI, {max:1, bands:["ndvi"], palette: ['gray','yellow','green']}, 'NDVIfull')

// //////////////////////////////////////////////////////////////////////

// // Get elevation to mask 0
// var elevation = ee.Image("USGS/SRTMGL1_003") // elevation data

// // apply mask    
// var wmask = NDVI.mask(elevation.neq(0))
// var NDVI2 = wmask.clipToCollection(city)
// //--------------------------------------------------------------
// // Map over feature collection, get the mean & sd NDVI
// var meanval = NDVI2.reduceRegions({
//   collection: city,
//   reducer: ee.Reducer.mean().setOutputs(['ndvi_mean']).combine({
// 		reducer2: ee.Reducer.stdDev().setOutputs(['ndvi_sd']),
//     sharedInputs: true
//   }),
//   scale: 10 // 10 meters
// });

// print(meanval.toList(6))

// Map.addLayer(NDVI2, {max:1, bands:["ndvi"], palette: ['gray','yellow','green']}, 'NDVI')

//----------------------------------------------------------------------
//----------------------------------------------------------------------
// Landsat data, filter for data - 10 years prior to 2018
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
var NDVI2 = wmask.clipToCollection(city)

Map.addLayer(NDVI2, {max:1, bands:["ndvi"], palette: ['gray','yellow','green']}, 'NDVI')

// //--------------------------------------------------------------
// // Map over feature collection, get the mean & sd NDVI
var meanval = NDVI2.reduceRegions({
  collection: city,
  reducer: ee.Reducer.mean().setOutputs(['ndvi_mean']).combine({
		reducer2: ee.Reducer.stdDev().setOutputs(['ndvi_sd']),
    sharedInputs: true
  }),
  scale: 30 // 30 meters for Landsat
});

print(meanval.toList(6))
