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

import org.appcelerator.kroll.KrollFunction;
import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.TiC;

import android.location.Address;
import android.location.Criteria;
import android.location.Geocoder;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;

@Kroll.proxy(creatableInModule  = BasicgeoModule.class)
public class CurrentGeolocationProxy extends KrollProxy {
	private Locale _currentLocale = Locale.getDefault();
	
	public CurrentGeolocationProxy() {
		super();
	}

	@Kroll.method @Kroll.setProperty
	public void setDistanceFilter(long Value){
		CommonHelpers.DebugLog("distanceFilter here is used for cross-platform compatibility. A distance of 0 will be used.");
	}

	@Kroll.method @Kroll.setProperty
	public void setPurpose(String Value){
		CommonHelpers.DebugLog("Purpose is used for cross-platform compatibility, android does not use this feature");
	}
    
	@Kroll.method @Kroll.setProperty
	public void setGeoLocale(String language){	
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

	    	CommonHelpers.DebugLog("[FIND ADDRESS] was successful");
            HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      	eventOk.put("placeCount",placeCount);
	      	eventOk.put("places",addressResult);
	      	eventOk.put(TiC.PROPERTY_SUCCESS, true);	
	      	eventOk.put("locationProvider", providerName);
	      	return eventOk;
	      		
        } catch (IOException e) {
        	Log.e(BasicgeoModule.MODULE_FULL_NAME, "[FIND ADDRESS] Error:",e);  				
  			HashMap<String, Object> eventErr = new HashMap<String, Object>();
  			eventErr.put("placeCount",0);
  			eventErr.put(TiC.PROPERTY_SUCCESS, false);
  			return eventErr;
        } finally {
      	  geocoder=null;
        } 		
	}
	
	public Location getLastBestLocation(LocationManager locationManager,int minDistance, long minTime) {
	    Location bestResult = null;
	    float bestAccuracy = Float.MAX_VALUE;
	    long bestTime = Long.MIN_VALUE;
	    
	    // Iterate through all the providers on the system, keeping
	    // note of the most accurate result within the acceptable time limit.
	    // If no result is found within maxTime, return the newest Location.
	    List<String> matchingProviders = locationManager.getAllProviders();
	    for (String provider: matchingProviders) {
	      Location location = locationManager.getLastKnownLocation(provider);
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
	public void getCurrentPlace(CriteriaProxy criteriaproxy,KrollFunction inputcallback){	
		final KrollFunction callback = inputcallback;
		Location cacheLocation = null;
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
		
	      if (!CommonHelpers.hasProviders()) {
		  		  if (callback != null) {      				
		    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
		    			eventErr.put("placeCount",0);
		    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
		    			eventErr.put("message","No Location Providers available");	
		    			callback.call(getKrollObject(), eventErr);
				  }         	
	      	return;
	      }
      
	    LocationManager locManager = (LocationManager) TiApplication.getInstance().getApplicationContext().getSystemService(TiApplication.LOCATION_SERVICE);
				      
	    if(criteriaproxy.getUseCache()){
	    	cacheLocation = getLastBestLocation(locManager,criteriaproxy.getCacheDistance(), criteriaproxy.getCacheTime());
	    }
	    if(cacheLocation!=null){
	    	callback.call(getKrollObject(), FindAddress(cacheLocation.getLatitude(),cacheLocation.getLongitude(),"lastFound"));
      		return;
	    }
	    
	    Criteria criteria = criteriaproxy.getCriteria();  	  
		String provider = locManager.getBestProvider(criteria, true);
		
		if(providerEmpty(provider)){
	  		if (callback != null) {      				
	  			HashMap<String, Object> eventErr = new HashMap<String, Object>();
				eventErr.put("placeCount",0);
				eventErr.put(TiC.PROPERTY_SUCCESS, false);
				eventErr.put("message","No Location Providers available");	
				callback.call(getKrollObject(), eventErr);
	  		} 
	  		return;
		}
		locManager.requestSingleUpdate(criteria, new LocationListener(){
	
	  	        @Override
	  	        public void onLocationChanged(Location location) {
	  	            	          	        	
	  				CommonHelpers.DebugLog("[ADDRESS SEARCH] onLocationChanged");
	  				
	  		        if(location==null){
		  			  		  if (callback != null) {      				
		  			    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
		  			    			eventErr.put("placeCount",0);
		  			    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
		  			    			eventErr.put("message","No Location Provided");	
		  			    			callback.call(getKrollObject(), eventErr);
		  					  }       	
		  		        }else{
		  		        	callback.call(getKrollObject(), FindAddress(location.getLatitude(),location.getLongitude(),location.getProvider()));	        	
		  		        }  
	
	  	        }
	
	  	        @Override
	  	        public void onProviderDisabled(String provider) {}
	  	        @Override
	  	        public void onProviderEnabled(String provider) {}
	  	        @Override
	  	        public void onStatusChanged(String provider, int status, Bundle extras) {}
	
	  	    }, null);  	
	}
	private boolean providerEmpty(String value){
		if(value == null){
			return true;
		}
		if(value.trim().length()==0){
			return true;
		}
		return false;
	}
	@Kroll.method
	public void getCurrentPosition(CriteriaProxy criteriaproxy,KrollFunction inputcallback){	
		final KrollFunction callback = inputcallback;
		Location cacheLocation = null;
		
        if (!CommonHelpers.hasProviders()) {
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put("placeCount",0);
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","No Location Providers available");	
	    			callback.call(getKrollObject(), eventErr);
			  }         	
        	return;
        }

		LocationManager locManager = (LocationManager) TiApplication.getInstance().getSystemService(TiApplication.LOCATION_SERVICE);
	    if(criteriaproxy.getUseCache()){
	    	cacheLocation = getLastBestLocation(locManager,
	    										criteriaproxy.getCacheDistance(), 
	    										criteriaproxy.getCacheTime());
	    }

	    if(cacheLocation!=null){
	    	callback.call(getKrollObject(), buildLocationEvent(cacheLocation, "lastFound"));
        	return;
	    }
	
    	Criteria criteria = criteriaproxy.getCriteria();
    	String provider = locManager.getBestProvider(criteria, true);
		if(providerEmpty(provider)){
	  		if (callback != null) {      				
	  			HashMap<String, Object> eventErr = new HashMap<String, Object>();
  				eventErr.put("placeCount",0);
  				eventErr.put(TiC.PROPERTY_SUCCESS, false);
  				eventErr.put("message","No Location Providers available");	
  				callback.call(getKrollObject(), eventErr);
	  		} 
	  		return;
		}
		
		locManager.requestSingleUpdate(provider, new LocationListener(){
    	        @Override
    	        public void onLocationChanged(Location location) {
    	            	          	        	
    				CommonHelpers.DebugLog("[COORD SEARCH] onLocationChanged");
    				
    		        if(location==null){    		        	
    		        	CommonHelpers.DebugLog("[COORD SEARCH] No coordinates found");
    			  		  if (callback != null) {      				
    			    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
    			    			eventErr.put("placeCount",0);
    			    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
    			    			eventErr.put("message","No Location Provided");	
    			    			callback.call(getKrollObject(), eventErr);
    					  }       	
    		        }else{
    		        	CommonHelpers.DebugLog("[COORD SEARCH] returning callback location provider " + location.getProvider());
    		        	callback.call(getKrollObject(), buildLocationEvent(location, location.getProvider()));		        	
    		        } 

    	        }

    	        @Override
    	        public void onProviderDisabled(String provider) {}
    	        @Override
    	        public void onProviderEnabled(String provider) {}
    	        @Override
    	        public void onStatusChanged(String provider, int status, Bundle extras) {}

    	    }, null);
		
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
