/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package bencoding.basicgeo;

import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;

import org.appcelerator.kroll.KrollDict;
import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;
import org.appcelerator.titanium.util.TiConvert;


import android.location.Address;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;

@Kroll.proxy(creatableInModule  = BasicgeoModule.class)
public class CurrentGeolocationProxy extends KrollProxy  {
	private Locale _currentLocale = Locale.getDefault(); 
	LocationManager _locationManager = null;
	private String _positionProviderName= "None";
	private String _placeProviderName= "None";
	private boolean _useCache = false;
	public CurrentGeolocationProxy() {
		super();
		_locationManager = (LocationManager) TiApplication.getInstance().getApplicationContext().getSystemService(TiApplication.LOCATION_SERVICE);
	}

	@Override
	public void handleCreationDict(KrollDict options)
	{
		super.handleCreationDict(options);
		if (options.containsKey("useCache")) {
			_useCache = TiConvert.toBoolean(options.get("useCache"));		
		}	
	}
	@Kroll.method
	public void setGeoLocale(Object[] args){
		final int kArgLanguage = 0;
		final int kArgCount = 1;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("one argument language is required");
		}
				
		// Use the TiConvert methods to get the values from the arguments
		String language = TiConvert.toString(args[kArgLanguage]);		
		_currentLocale= new Locale(language);
		CommonHelpers.DebugLog("Locale is now " + _currentLocale.toString());
	}

	@Kroll.method
	public boolean reverseGeoIsSupported(){		
		return CommonHelpers.reverseGeoSupported();
	}
	
	
	private HashMap<String, Object> FindAddress(double latitude, double longitude,String providerName){
	      Geocoder geocoder = new Geocoder(TiApplication.getInstance().getApplicationContext(), _currentLocale);   
	      
	      try {            
	    	  List<Address> list = geocoder.getFromLocation(latitude,longitude,1);            
	    	  int placeCount = list.size();            
	    	  Object[] addressResult = new Object[placeCount];            
	    	  if (list != null && placeCount > 0) {            	  	          
	    		  for (int iLoop = 0; iLoop < placeCount; iLoop++) {	          		
	    			  addressResult[iLoop]= CommonHelpers.buildAddress(latitude,longitude,list.get(iLoop));	          		
	    		  }
	    	  }

	    	CommonHelpers.DebugLog("[REVERSEGEO] was successful");
            HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      	eventOk.put("placeCount",placeCount);
	      	eventOk.put("places",addressResult);
	      	eventOk.put(TiC.PROPERTY_SUCCESS, true);	
	      	eventOk.put("locationProvider", providerName);
	      	return eventOk;
	      		
        } catch (IOException e) {
        	Log.e(BasicgeoModule.MODULE_FULL_NAME, "[REVERSEGEO] Error:",e);  				
  			HashMap<String, Object> eventErr = new HashMap<String, Object>();
  			eventErr.put("placeCount",0);
  			eventErr.put(TiC.PROPERTY_SUCCESS, false);
  			return eventErr;
        } finally {
      	  geocoder=null;
        } 		
	}
	
	
	private boolean hasProviders(){
	   
        return (_locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER) || 
        		_locationManager.isProviderEnabled(LocationManager.PASSIVE_PROVIDER) || 
        		_locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER));
	}

	public Location getLastBestLocation(int minDistance, long minTime) {
	    Location bestResult = null;
	    float bestAccuracy = Float.MAX_VALUE;
	    long bestTime = Long.MIN_VALUE;
	    
	    // Iterate through all the providers on the system, keeping
	    // note of the most accurate result within the acceptable time limit.
	    // If no result is found within maxTime, return the newest Location.
	    List<String> matchingProviders = _locationManager.getAllProviders();
	    for (String provider: matchingProviders) {
	      Location location = _locationManager.getLastKnownLocation(provider);
	      if (location != null) {
	        float accuracy = location.getAccuracy();
	        long time = location.getTime();
	        
	        if ((time > minTime && accuracy < bestAccuracy)) {
	          bestResult = location;
	          bestAccuracy = accuracy;
	          bestTime = time;
	        }
	        else if (time < minTime && bestAccuracy == Float.MAX_VALUE && time > bestTime) {
	          bestResult = location;
	          bestTime = time;
	        }
	      }
	    }

	    
	    return bestResult;
	  }
	
	@Kroll.method
	public void getCurrentPlace(Object[] args){	
		final int kArgCallback = 0;
		final int kArgCount = 1;
		Location cacheLocation = null;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("You must provide a callback");
		}	
		
		Object object = args[kArgCallback];
		final KrollFunction callback = (KrollFunction)object;
		
		if(!CommonHelpers.reverseGeoSupported()){
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put("placeCount",0);
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","Reverse Geo Location is not supported, see console for details");	
	    			callback.call(getKrollObject(), eventErr);
			  }         	
	  		  return;
		}
		
        if (!hasProviders()) {
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put("placeCount",0);
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","No Location Providers available");	
	    			callback.call(getKrollObject(), eventErr);
			  }         	
        	return;
        }
        
		 LocationListener locationListener = new LocationListener(){

			@Override
			public void onLocationChanged(Location location) {	
				_locationManager.removeUpdates(this);
		        if(location==null){
			  		  if (callback != null) {      				
			    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
			    			eventErr.put("placeCount",0);
			    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
			    			eventErr.put("message","No Location Provided");	
			    			callback.call(getKrollObject(), eventErr);
					  }       	
		        }else{
		        	callback.call(getKrollObject(), FindAddress(location.getLatitude(),location.getLongitude(),_placeProviderName));
		        }   		       	
			}

			@Override
			public void onProviderDisabled(String arg0) {
				
			}

			@Override
			public void onProviderEnabled(String arg0) {
				
			}

			@Override
			public void onStatusChanged(String arg0, int arg1, Bundle arg2) {
				
			}
		};
	    
	    if(_useCache){
	    	cacheLocation = getLastBestLocation(10, 30000);
	    }
	    if(cacheLocation!=null){
        	callback.call(getKrollObject(), FindAddress(cacheLocation.getLatitude(),cacheLocation.getLongitude(),"lastFound"));	    	
	    }
	    
        // if GPS Enabled get lat/long using GPS Services
    	if (_locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
    		_placeProviderName ="GPS";
    		_locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,0,0, locationListener);
            CommonHelpers.DebugLog("[REVERSEGEO] Using GPS Provider");
        }else{
        	if (_locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {          
        		_placeProviderName ="Network";
        		_locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,0,0, locationListener);
                CommonHelpers.DebugLog("[REVERSEGEO] Using Network Provider");  
        	}else{
            	if (_locationManager.isProviderEnabled(LocationManager.PASSIVE_PROVIDER)) {   
            		_placeProviderName ="Passive";
            		_locationManager.requestLocationUpdates(LocationManager.PASSIVE_PROVIDER,0,0, locationListener);
                    CommonHelpers.DebugLog("[REVERSEGEO] Using Passive Provider");  
            	}else{
	      	  		if (callback != null) {      				
	  	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	  	    			eventErr.put("placeCount",0);
	  	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	  	    			eventErr.put("message","No Location Providers available");	
	  	    			callback.call(getKrollObject(), eventErr);
	  			  }           		
            	}        		
        	}
        }
    	
	}
	@Kroll.method
	public void getCurrentPosition(Object[] args){	

		final int kArgCallback = 0;
		final int kArgCount = 1;
		Location cacheLocation = null;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("You must provide a callback");
		}	

		Object object = args[kArgCallback];
		final KrollFunction callback = (KrollFunction)object;
		
        if (!hasProviders()) {
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","No Location Providers available");	
	    			callback.call(getKrollObject(), eventErr);
			  }         	
        	return;
        }
        
		 LocationListener locationListener = new LocationListener(){

			@Override
			public void onLocationChanged(Location location) {	
				_locationManager.removeUpdates(this);
		        if(location==null){
			  		  if (callback != null) {      				
			    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
			    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
			    			eventErr.put("message","No Location Provided");	
			    			callback.call(getKrollObject(), eventErr);
					  }       	
		        }else{
		        	callback.call(getKrollObject(), buildLocationEvent(location, _positionProviderName));
		        } 		       	
			}

			@Override
			public void onProviderDisabled(String arg0) {
				
			}

			@Override
			public void onProviderEnabled(String arg0) {
				
			}

			@Override
			public void onStatusChanged(String arg0, int arg1, Bundle arg2) {
				
			}
		};

	    if(_useCache){
	    	cacheLocation = getLastBestLocation(10, 30000);
	    }
	    if(cacheLocation!=null){
        	callback.call(getKrollObject(), FindAddress(cacheLocation.getLatitude(),cacheLocation.getLongitude(),"lastFound"));	    	
	    }
	    
       // if GPS Enabled get lat/long using GPS Services
   	if (_locationManager.isProviderEnabled(LocationManager.GPS_PROVIDER)) {
   		   _positionProviderName ="GPS";
           _locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER,0,0, locationListener);
           CommonHelpers.DebugLog("[REVERSEGEO] Using GPS Provider");
       }else{
       	if (_locationManager.isProviderEnabled(LocationManager.NETWORK_PROVIDER)) {          
       		_positionProviderName ="Network";
       		_locationManager.requestLocationUpdates(LocationManager.NETWORK_PROVIDER,0,0, locationListener);
            CommonHelpers.DebugLog("[REVERSEGEO] Using Network Provider");  
       	}else{
           	if (_locationManager.isProviderEnabled(LocationManager.PASSIVE_PROVIDER)) {   
           		_positionProviderName ="Passive";
                _locationManager.requestLocationUpdates(LocationManager.PASSIVE_PROVIDER,0,0, locationListener);
                CommonHelpers.DebugLog("[REVERSEGEO] Using Passive Provider");  
           	}else{
	      	  		if (callback != null) {      				
	  	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	  	    			eventErr.put("placeCount",0);
	  	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	  	    			eventErr.put("message","No Location Providers available");	
	  	    			callback.call(getKrollObject(), eventErr);
	  			  }           		
           	}        		
       	}
       }
        
	}
	
	private HashMap<String, Object> buildLocationEvent(Location location,String providerName)
	{
		HashMap<String, Object> coordinates = new HashMap<String, Object>();
		coordinates.put("locationProvider", providerName);
		coordinates.put(TiC.PROPERTY_LATITUDE, location.getLatitude());
		coordinates.put(TiC.PROPERTY_LONGITUDE, location.getLongitude());
		coordinates.put(TiC.PROPERTY_ALTITUDE, location.getAltitude());
		coordinates.put(TiC.PROPERTY_ACCURACY, location.getAccuracy());
		coordinates.put(TiC.PROPERTY_ALTITUDE_ACCURACY, null); // Not provided
		coordinates.put(TiC.PROPERTY_HEADING, location.getBearing());
		coordinates.put(TiC.PROPERTY_SPEED, location.getSpeed());
		coordinates.put(TiC.PROPERTY_TIMESTAMP, location.getTime());

		HashMap<String, Object> event = new HashMap<String, Object>();
		event.put(TiC.PROPERTY_SUCCESS, true);
		event.put(TiC.PROPERTY_COORDS, coordinates);

		return event;
	}	
}
