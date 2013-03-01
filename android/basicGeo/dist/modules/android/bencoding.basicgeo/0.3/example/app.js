var basicGeo = require('bencoding.basicgeo');
Ti.API.info("module is => " + basicGeo);
var isAndroid = Ti.Platform.osname == "android";
Ti.API.info("Are we working with Android? " + isAndroid);

if(!isAndroid){
	//Set why we need to use location services
	basicGeo.purpose = "Demo of Location Services";	
}


Ti.API.info("We have a few helpers here are some examples");
var helpers = basicGeo.createHelpers();
Ti.API.info("How far is it between time square and the empire state building?");
var timeSq2Emipre=helpers.distanceBetweenInMeters(40.75773,-73.985708,40.748433, -73.985656);
Ti.API.info(timeSq2Emipre +" meters");
Ti.API.info("How far is it from Times Square to Red Square?");
var timeSq2Red=helpers.distanceBetweenInMeters(40.75773,-73.985708,55.754167, 37.62);
Ti.API.info(timeSq2Red +" meters");	
	
if(!isAndroid){
	var available = basicGeo.createAvailability(); 
	Ti.API.info("are location services enabled for this device and app? " + available.locationServicesEnabled);
	Ti.API.info("is region monitoring (geo fencing) available? " + available.regionMonitoringAvailable);
	Ti.API.info("are we using region monitoring (geo fencing)? " + available.regionMonitoringEnabled);
	Ti.API.info("what is our location services authorization status? " + available.locationServicesAuthorization);
}

function showPlace(place){
		
	Ti.API.info("CountryCode " + place.countryCode);
	Ti.API.info("CountryName " + place.countryName);
	Ti.API.info("AdminArea " + place.administrativeArea);
	Ti.API.info("SubAdminArea " + place.subAdministrativeArea);
    Ti.API.info("Locality " + place.locality);
    Ti.API.info("SubLocality " + place.subLocality);
    Ti.API.info("Thoroughfare " + place.thoroughfare);                      
	Ti.API.info("SubThoroughfare " + place.subThoroughfare); 
    Ti.API.info("PostalCode " + place.postalCode);  
	    
	if((place.latitude!=undefined)&&(place.latitude!=null)){
		Ti.API.info("latitude " + place.latitude);  	
	}
    if((place.longitude!=undefined)&&(place.longitude!=null)){       
  		Ti.API.info("longitude " + place.longitude);   
  	}
  	
  	Ti.API.info("Each platform has some custom elements so highlight them.");
  	if(isAndroid){
  		Ti.API.info("Address " + place.address);
	    Ti.API.info("phone " + place.phone); 
	    Ti.API.info("url " + place.url);     	  		
  	}else{
  		Ti.API.info("region " + JSON.stringify(place.region)); 
  		Ti.API.info("timestamp " + new Date(place.timestamp));
  	}
};

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
	Ti.API.info("Forward Results stringified" + test);
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

Ti.API.info("Now let's check out the GeoCoders")
var geo = basicGeo.createGeocoder();

if(isAndroid){
	Ti.API.info("We can set the locale we want to work with");
	Ti.API.info("Let's try Japanese");
	geo.setGeoLocale('ja');
}

if(isAndroid){
	Ti.API.info("Android as a bug in the emulator so we need to check this");
	if(!geo.isSupported()){
		alert("Your configuration isn't supported. If you are running in the emulator you need to use 4.0 or higher due to a Google Emulator bug. Or you can test on device.");
	}	
}else{
	Ti.API.info("We use some iOS5 APIs so we check that we are at least running iOS5");
	if(!geo.isSupported()){
		Ti.API.info("You are not running a supported version of the iOS some functions might not work");
	}
}

Ti.API.info("Now let's do some forward Geo and lookup the address for Appcelerator HQ");
var address="440 N. Bernardo Avenue Mountain View, CA";

Ti.API.info("We call the forward Geocoder providing an address and callback");
Ti.API.info("Now we wait for the lookup");
geo.forwardGeocoder(address,forwardGeoCallback);

Ti.API.info("Let's now try to do a reverse Geo lookup using the Time Square coordinates");
Ti.API.info("Pass in our coordinates and callback then wait...");
geo.reverseGeocoder(40.75773,-73.985708,reverseGeoCallback);

Ti.API.info("Now let's use the Current Geolocation functions");
var currentGeo = basicGeo.createCurrentGeolocation();

function resultsCallback(e){
    Ti.API.info("Did it work? " + e.success);
    if(e.success){
        Ti.API.info("It worked");
    }   

    var test = JSON.stringify(e);
    Ti.API.info("Results stringified" + test);
};

Ti.API.info("Let's get the places information (address) for our current location");
Ti.API.info("We make our call and provide a callback then wait...");
currentGeo.getCurrentPlace(resultsCallback);
