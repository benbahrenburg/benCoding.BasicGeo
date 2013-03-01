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
import org.appcelerator.titanium.TiApplication;
import org.appcelerator.titanium.util.TiConvert;
import org.appcelerator.kroll.common.Log;


import android.location.Address;
import android.location.Geocoder;

@Kroll.proxy(creatableInModule  = BasicgeoModule.class)
public class GeocoderProxy extends KrollProxy  {

	private static int ForwardResultsLimit=1;
	private static int ReverseResultsLimit=1;
	private Locale currentLocale = Locale.getDefault(); 
	public GeocoderProxy() {
		super();
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
		currentLocale= new Locale(language);
		CommonHelpers.DebugLog("Locale is now " + currentLocale.toString());
	}
	@Kroll.method
	public boolean isSupported(){		
		return CommonHelpers.reverseGeoSupported();
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

		Geocoder geocoder = new Geocoder(TiApplication.getInstance().getApplicationContext(), currentLocale);
        try {      		
      	 
            List<Address> list = geocoder.getFromLocationName(findAddress,ForwardResultsLimit);
            int placeCount = list.size();
            Object[] addressResult = new Object[placeCount];
            if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          			addressResult[iLoop]=CommonHelpers.buildAddress(list.get(iLoop));
	          		}
            }
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
    		  }              
    		  CommonHelpers.DebugLog("[FORWARDGEO] was successful");
        } catch (IOException e) {
    		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);
	      			eventErr.put("message",e.getMessage());	
	    			callback.call(getKrollObject(), eventErr);
    		  }       
    		  CommonHelpers.DebugLog("[FORWARDGEO] Geocoder error");
    		  CommonHelpers.Log(e);
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
		
	      Geocoder geocoder = new Geocoder(TiApplication.getInstance().getApplicationContext(), currentLocale);   
          try {  
        	
              List<Address> list = geocoder.getFromLocation(latitude,longitude,ReverseResultsLimit);
              int placeCount = list.size();
              Object[] addressResult = new Object[placeCount];
              if (list != null && placeCount > 0) {            	  
	          	  for (int iLoop = 0; iLoop < placeCount; iLoop++) {
	          		addressResult[iLoop]= CommonHelpers.buildAddress(latitude,longitude,list.get(iLoop));
	          		}
              }
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventOk = new HashMap<String, Object>();
	      			eventOk.put("placeCount",placeCount);
	      			eventOk.put("places",addressResult);
	      			eventOk.put("success",true);	
	    			callback.call(getKrollObject(), eventOk);
      		  }   
      		CommonHelpers.DebugLog("[REVERSEGEO] was successful");
          } catch (IOException e) {
      		  if (callback != null) {      				
	      			HashMap<String, Object> eventErr = new HashMap<String, Object>();
	      			eventErr.put("placeCount",0);
	      			eventErr.put("success",false);	
	    			callback.call(getKrollObject(), eventErr);
	    			CommonHelpers.DebugLog("[REVERSEGEO] callback error called");
      		  }          	
              Log.e(BasicgeoModule.MODULE_FULL_NAME, "[REVERSEGEO] Geocoder error", e);
          } finally {
        	  geocoder=null;
          }        
	}	
}
