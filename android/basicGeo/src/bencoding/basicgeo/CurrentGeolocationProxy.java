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
	
	
	private HashMap<String, Object> FindAddress(double latitude, double longitude){
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
	private Location findCurrentLocation(){
		// Get the location manager
		LocationManager locationManager = (LocationManager) TiApplication.getInstance().getApplicationContext().getSystemService(TiApplication.LOCATION_SERVICE);		
	
		Location location = null;
		Location networkLocation = null;
		Location gpsLocation = null;
		Location passiveLocation = null;
        // getting GPS status
        boolean isGPSEnabled = locationManager
                .isProviderEnabled(LocationManager.GPS_PROVIDER);

        // getting network status
        boolean isNetworkEnabled = locationManager
                .isProviderEnabled(LocationManager.NETWORK_PROVIDER);

        // getting network status
        boolean isPassiveEnabled = locationManager
                .isProviderEnabled(LocationManager.PASSIVE_PROVIDER);
        
		final LocationListener locationListener = new LocationListener(){

			@Override
			public void onLocationChanged(Location location) {	
			
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

            // if GPS Enabled get lat/long using GPS Services
            if (isGPSEnabled) {                    
                locationManager.requestLocationUpdates(
                        LocationManager.GPS_PROVIDER,0,0, locationListener);
                CommonHelpers.DebugLog("[REVERSEGEO] Using GPS Provider");
                if (locationManager != null) {
                	gpsLocation = locationManager
                            .getLastKnownLocation(LocationManager.GPS_PROVIDER);
                    	locationManager.removeUpdates(locationListener);  
                    	location= gpsLocation;
                }
            }
            // Network Provider
            if (isNetworkEnabled) {
            	if (location == null) {
                    locationManager.requestLocationUpdates(
                            LocationManager.NETWORK_PROVIDER,0,0, locationListener);
                    CommonHelpers.DebugLog("[REVERSEGEO] Using Network Provider");
                    if (locationManager != null) {
                    	networkLocation = locationManager
                                .getLastKnownLocation(LocationManager.NETWORK_PROVIDER);
                    	locationManager.removeUpdates(locationListener);                    	
                    }
            	}
            }

        	if((location==null) && (networkLocation!=null)){
        		location = networkLocation;
        	}else{
        		if((gpsLocation!=null) && (networkLocation!=null)){
                    if (gpsLocation.getTime() > networkLocation.getTime()) {
                    	location = gpsLocation;
                    }else{
                    	location = networkLocation;
                    }  
        		}
        	}
        	
            // Network Provider
            if (isPassiveEnabled) {
            	if (location == null) {
                    locationManager.requestLocationUpdates(
                            LocationManager.PASSIVE_PROVIDER,0,0, locationListener);
                    CommonHelpers.DebugLog("[REVERSEGEO] Using Passive Provider");
                    passiveLocation = locationManager
					        .getLastKnownLocation(LocationManager.PASSIVE_PROVIDER);
					locationManager.removeUpdates(locationListener);				
            	}
            }

        	if((location==null) && (passiveLocation!=null)){
        		location = passiveLocation;
        	}else{
        		if((location!=null) && (passiveLocation!=null)){
                    if (passiveLocation.getTime() > location.getTime()) {
                    	location = passiveLocation;
                    } 
        		}     		
        	}

            return location;
	};
	private boolean hasProviders(){
		LocationManager locationManager = (LocationManager) TiApplication.getInstance().getApplicationContext().getSystemService(TiApplication.LOCATION_SERVICE);		
		
        // getting GPS status
        boolean isGPSEnabled = locationManager
                .isProviderEnabled(LocationManager.GPS_PROVIDER);

        // getting network status
        boolean isNetworkEnabled = locationManager
                .isProviderEnabled(LocationManager.NETWORK_PROVIDER);

        // getting network status
        boolean isPassiveEnabled = locationManager
                .isProviderEnabled(LocationManager.PASSIVE_PROVIDER);
      
        return (isGPSEnabled && isNetworkEnabled && isPassiveEnabled);
	}
	@Kroll.method
	public void getCurrentPlace(Object[] args){	

		final int kArgCallback = 0;
		final int kArgCount = 1;
		
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
        
        Location location = findCurrentLocation();
        
        if(location==null){
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put("placeCount",0);
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","No Location Provided");	
	    			callback.call(getKrollObject(), eventErr);
			  }       	
        }else{
        	callback.call(getKrollObject(), FindAddress(location.getLatitude(),location.getLongitude()));
        }        
	}
	@Kroll.method
	public void getCurrentPosition(Object[] args){	

		final int kArgCallback = 0;
		final int kArgCount = 1;
		
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
        
        Location location = findCurrentLocation();
        
        if(location==null){
	  		  if (callback != null) {      				
	    			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	    			eventErr.put(TiC.PROPERTY_SUCCESS, false);
	    			eventErr.put("message","No Location Provided");	
	    			callback.call(getKrollObject(), eventErr);
			  }       	
        }else{
        	callback.call(getKrollObject(), buildLocationEvent(location));
        }  

	}
	
	private HashMap<String, Object> buildLocationEvent(Location location)
	{
		HashMap<String, Object> coordinates = new HashMap<String, Object>();
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
