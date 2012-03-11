var basicGeo = require('bencoding.basicgeo');
Ti.API.info("module is => " + basicGeo);

Ti.API.info("Let's test our helpers first");
var helpers = basicGeo.createHelpers();
Ti.API.info("How far is it between time square and the empire state building?");
var timeSq2Emipre=helpers.distanceBetweenInMeters(40.75773,-73.985708,40.748433, -73.985656);
Ti.API.info(timeSq2Emipre +" meters");
Ti.API.info("How far is it from Times Square to Red Square?");
var timeSq2Red=helpers.distanceBetweenInMeters(40.75773,-73.985708,55.754167, 37.62);
Ti.API.info(timeSq2Red +" meters");

Ti.API.info("Now let's check out the GeoCoders")
var geo = basicGeo.createGeocoder();

Ti.API.info("We use some iOS5 APIs so we check that we are at least running iOS5");
if(!geo.isSupported()){
	Ti.API.info("You are not running a supported version of the iOS some functions might not work");
}

Ti.API.info("Now let's do some forward Geo and lookup the address for Appcelerator HQ");
var address="440 N. Bernardo Avenue Mountain View, CA";

function showPlace(place){
	
	Ti.API.info("ISOcountryCode " + place.ISOcountryCode);
	Ti.API.info("country " + place.country);
	Ti.API.info("postalCode " + place.postalCode);
	Ti.API.info("administrativeArea " + place.administrativeArea);
	Ti.API.info("subAdministrativeArea " + place.subAdministrativeArea);
    Ti.API.info("locality " + place.locality);
    Ti.API.info("subLocality " + place.subLocality);
    Ti.API.info("thoroughfare " + place.thoroughfare);                      
	Ti.API.info("subThoroughfare " + place.subThoroughfare); 
    Ti.API.info("region " + JSON.stringify(place.region));   
    Ti.API.info("latitude " + place.latitude);         
  	Ti.API.info("longitude " + place.longitude);   	
	Ti.API.info("timestamp " + new Date(place.timestamp));
};
function forwardGeoCallback(e){
	Ti.API.info("Did it work? " + e.success);
	if(e.success){
		Ti.API.info("This is the number of places found, it can return many depending on your search");
		Ti.API.info("Places found = " + e.placeCount);
		for (var iLoop=0;iLoop<e.placeCount;iLoop++){
			Ti.API.info("Showing Place At Index " + iLoop);
			showPlace(e.places[iLoop]);
		}		
	}	

	var test = JSON.stringify(e);
	Ti.API.info("Forward Results stringified" + test);
};

Ti.API.info("We call the forward Geocoder providing an address and callback");
Ti.API.info("Now we wait for the lookup");
geo.forwardGeocoder(address,forwardGeoCallback);

function reverseGeoCallback(e){
	Ti.API.info("Did it work? " + e.success);
	if(e.success){
		Ti.API.info("This is the number of places found, it can return many depending on your search");
		Ti.API.info("Places found = " + e.placeCount);
		for (var iLoop=0;iLoop<e.placeCount;iLoop++){
			Ti.API.info("Showing Place At Index " + iLoop);
			showPlace(e.places[iLoop]);
		}		
	}	
	var test = JSON.stringify(e);
	Ti.API.info("Reverse Geo Results stringified" + test);
};

Ti.API.info("Let's now try to do a reverse Geo lookup using the Time Square coordinates");
Ti.API.info("Pass in our coordinates and callback then wait...");
geo.reverseGeocoder(40.75773,-73.985708,reverseGeoCallback);
