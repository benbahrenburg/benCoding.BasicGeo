/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package bencoding.basicgeo;

import java.io.IOException;
import java.util.ArrayList;
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


@Kroll.proxy(creatableInModule = BasicgeoModule.class)
public class GeocoderProxy extends KrollProxy  {
	// Standard Debugging variables
	private static final String LCAT = "BasicgeoModule";
	private static int ForwardResultsLimit=1;
	private static int ReverseResultsLimit=1;
	public GeocoderProxy() {
		super();
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
			
		results.put("Address", sb.toString());
		results.put("CountryCode", place.getCountryCode());
		results.put("CountryName", place.getCountryName());
		results.put("AdminArea", place.getAdminArea());
		results.put("SubAdminArea", place.getSubAdminArea());
		results.put("Locality", place.getLocality());
		results.put("SubLocality", place.getSubLocality());
		results.put("PostalCode", place.getPostalCode());
		results.put("Thoroughfare", place.getThoroughfare());
		results.put("SubThoroughfare", place.getSubThoroughfare());		
		try{
			results.put("phone", place.getPhone());
		 } catch (Exception e) {
			 results.put("phone", "");
		}
		results.put("url", place.getUrl());
		
		return results;		
	}
	private HashMap<String, Object> buildAddress(double lat, double lng, Address place)
	{
		HashMap<String, Object> results = buildAddress(place);
		if(place.hasLatitude()){
			results.put("Latitude", place.getLatitude());
		}else{
			results.put("Latitude", lat);			
		}
		if(place.hasLongitude()){
			results.put("Longitude", place.getLongitude());
		}else{
			results.put("Longitude", lng);
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
      	  ArrayList<HashMap<String, Object>> addressResult = new ArrayList<HashMap<String, Object>>();
            List<Address> list = geocoder.getFromLocationName(findAddress,ForwardResultsLimit);
            int placeCount = list.size();
            if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          			addressResult.add(buildAddress(list.get(iLoop)));
	          		}
            }
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
    				Log.d(LCAT,"[REVERSEGEO] callback was called successfully");
    		  }              
        } catch (IOException e) {
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);	
	    			callback.call(getKrollObject(), eventErr);
    				Log.d(LCAT,"[REVERSEGEO] callback error called");
    		  }          	
            Log.e(LCAT, "Impossible to connect to Geocoder", e);
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
        	  ArrayList<HashMap<String, Object>> addressResult = new ArrayList<HashMap<String, Object>>();
              List<Address> list = geocoder.getFromLocation(latitude,longitude,ReverseResultsLimit);
              int placeCount = list.size();
              if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          			addressResult.add(buildAddress(latitude,longitude,list.get(iLoop)));
	          		}
              }
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
      				Log.d(LCAT,"[REVERSEGEO] callback was called successfully");
      		  }              
          } catch (IOException e) {
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);	
	    			callback.call(getKrollObject(), eventErr);
      				Log.d(LCAT,"[REVERSEGEO] callback error called");
      		  }          	
              Log.e(LCAT, "Impossible to connect to Geocoder", e);
          } finally {
        	  geocoder=null;
          }        
	}	
}
