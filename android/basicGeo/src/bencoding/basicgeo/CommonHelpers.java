/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
package bencoding.basicgeo;

import java.util.HashMap;

import org.appcelerator.kroll.common.Log;

import android.location.Address;
import android.os.Build;

public class CommonHelpers {

	private static boolean _writeToLog = true;
	public static void UpdateWriteStatus(boolean value){
		_writeToLog = value;
	}

	public static void  Log(String message){
		if(_writeToLog){
			Log.i(BasicgeoModule.MODULE_FULL_NAME, message);
		}
		
	}
	public static void  Log(Exception e){
		if(_writeToLog){
			Log.i(BasicgeoModule.MODULE_FULL_NAME, e.toString());
		}
		
	}	
	public static void DebugLog(String message){
		if(_writeToLog){
			Log.d(BasicgeoModule.MODULE_FULL_NAME, message);
		}
	}
	public static HashMap<String, Object> buildAddress(double lat, double lng, Address place)
	{
		HashMap<String, Object> results = CommonHelpers.buildAddress(place);
		//If we can't get lat and lng from the GeoCoder, add them in
		if(!place.hasLatitude()){
			results.put("latitude", lat);			
		}
		if(!place.hasLongitude()){
			results.put("longitude", lng);
		}
		return results;
	}

	public static HashMap<String, Object> buildAddress(Address place)
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
	public static Boolean reverseGeoSupported(){
		if("google_sdk".equals( Build.PRODUCT )) {
			Log.d(BasicgeoModule.MODULE_FULL_NAME, "You are in the emulator, now checking if you have the min API level required");
			if(Build.VERSION.SDK_INT<14){
				Log.e(BasicgeoModule.MODULE_FULL_NAME, "You need to run API level 14 (ICS) or greater to work in emulator");
				Log.e(BasicgeoModule.MODULE_FULL_NAME, "This is a google emulator bug. Sorry you need to test on device.");
				return false;
			}else{
				return true;
			}
		}else{
			return true;
		}		
	}
}
