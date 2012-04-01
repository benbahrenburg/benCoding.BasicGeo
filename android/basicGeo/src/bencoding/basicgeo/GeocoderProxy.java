/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
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
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.kroll.common.Log;


import android.location.Address;
import android.location.Geocoder;
import android.os.Build;

@Kroll.proxy(creatableInModule = BasicgeoModule.class)
public class GeocoderProxy extends KrollProxy  {
	// Standard Debugging variables
	private static final String LCAT = "BasicgeoModule";
	private static int ForwardResultsLimit=1;
	private static int ReverseResultsLimit=1;
	public GeocoderProxy() {
		super();
	}
	
	@Kroll.getProperty @Kroll.method
	public boolean isSupported(){		
		if("google_sdk".equals( Build.PRODUCT )) {
			Log.d(LCAT, "You are in the emulator, now checking if you have the min API level required");
			if(Build.VERSION.SDK_INT<14){
				Log.d(LCAT, "You need to run API level 14 (ICS) or greater to work in emulator");
				Log.d(LCAT, "This is a google emulator bug. Sorry you need to test on device.");
				return false;
			}else{
				return true;
			}
		}else{
			return true;
		}
	}
	private HashMap<String, Object> buildAddress(Address place)
	{
		HashMap<String, Object> results = new HashMap<String, Object>();
		int addressLoop = 0;
		StringBuilder sb = new StringBuilder();
		for (addressLoop = 0; addressLoop < place.getMaxAddressLineIndex(); addressLoop++){
			if(addressLoop==0){
				sb.append("\n");
			}
			sb.append(place.getAddressLine(addressLoop));
		}		
			
		results.put("address", sb.toString());
		results.put("countryCode", place.getCountryCode());
		results.put("countryName", place.getCountryName());
		results.put("administrativeArea", place.getAdminArea());
		results.put("subAdministrativeArea", place.getSubAdminArea());
		results.put("locality", place.getLocality());
		results.put("subLocality", place.getSubLocality());
		results.put("postalCode", place.getPostalCode());
		results.put("thoroughfare", place.getThoroughfare());
		results.put("subThoroughfare", place.getSubThoroughfare());		
		try{
			results.put("phone", place.getPhone());
		 } catch (Exception e) {
			 results.put("phone", "");
		}
		results.put("url", place.getUrl());

		if(place.hasLatitude()){
			results.put("latitude", place.getLatitude());
		}
		if(place.hasLongitude()){
			results.put("longitude", place.getLongitude());
		}
		return results;		
	}
	private HashMap<String, Object> buildAddress(double lat, double lng, Address place)
	{
		HashMap<String, Object> results = buildAddress(place);
		//If we can't get lat and lng from the GeoCoder, add them in
		if(!place.hasLatitude()){
			results.put("latitude", lat);			
		}
		if(!place.hasLongitude()){
			results.put("longitude", lng);
		}
		return results;
	}

	@Kroll.method
	public void forwardGeocoderResultsLimit(Object[] args)
	{
		ForwardResultsLimit = (args[0] != null) ? TiConvert.toInt(args[0]) : 1;
	}
	@Kroll.method
	public void forwardGeocoder(Object[] args)
	{
		final int kArgAddress = 0;
		final int kArgCallback = 1;
		final int kArgCount = 2;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("At least 2 arguments required for method: address and a callback");
		}	
		// Use the TiConvert methods to get the values from the arguments
		String findAddress = (args[kArgAddress] != null) ? TiConvert.toString(args[kArgAddress]) : "";
		KrollFunction callback = null;
		Object object = args[kArgCallback];
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}		

		Geocoder geocoder = new Geocoder(TiApplication.getInstance().getApplicationContext(), Locale.getDefault());
        try {      		
      	 
            List<Address> list = geocoder.getFromLocationName(findAddress,ForwardResultsLimit);
            int placeCount = list.size();
            Object[] addressResult = new Object[placeCount];
            if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          			addressResult[iLoop]=buildAddress(list.get(iLoop));
	          		}
            }
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
    		  }              
				Log.d(LCAT,"[FORWARDGEO] was successful");
        } catch (IOException e) {
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);	
	    			callback.call(getKrollObject(), eventErr);
    		  }          	
            Log.e(LCAT, "[FORWARDGEO] Geocoder error", e);
        } finally {
      	  geocoder=null;
        } 		
	}
	@Kroll.method
	public void ReverseGeocoderResultsLimit(Object[] args)
	{
		ReverseResultsLimit = (args[0] != null) ? TiConvert.toInt(args[0]) : 1;
	}
	@Kroll.method
	public void reverseGeocoder(Object[] args)
	{
		final int kArgLatitude = 0;
		final int kArgLongitude = 1;
		final int kArgCallback = 2;
		final int kArgCount = 3;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("At least 3 arguments required for method: latitude, longitude, and a callback");
		}	
		// Use the TiConvert methods to get the values from the arguments
		double latitude = (args[kArgLatitude] != null) ? TiConvert.toDouble(args[kArgLatitude]) : 0;
		double longitude = (args[kArgLongitude] != null) ? TiConvert.toDouble(args[kArgLongitude]) : 0;
		KrollFunction callback = null;
		Object object = args[kArgCallback];
		if (object instanceof KrollFunction) {
			callback = (KrollFunction)object;
		}
		
	      Geocoder geocoder = new Geocoder(TiApplication.getInstance().getApplicationContext(), Locale.getDefault());   
          try {  
        	
              List<Address> list = geocoder.getFromLocation(latitude,longitude,ReverseResultsLimit);
              int placeCount = list.size();
              Object[] addressResult = new Object[placeCount];
              if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          		addressResult[iLoop]= buildAddress(latitude,longitude,list.get(iLoop));
	          		}
              }
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
      		  }   
      		Log.d(LCAT,"[REVERSEGEO] was successful");
          } catch (IOException e) {
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);	
	    			callback.call(getKrollObject(), eventErr);
      				Log.d(LCAT,"[REVERSEGEO] callback error called");
      		  }          	
              Log.e(LCAT, "[REVERSEGEO] Geocoder error", e);
          } finally {
        	  geocoder=null;
          }        
	}	
}
