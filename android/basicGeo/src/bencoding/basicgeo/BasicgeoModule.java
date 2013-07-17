/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

package bencoding.basicgeo;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;

import android.location.Criteria;

@Kroll.module(name="Basicgeo", id="bencoding.basicgeo")
public class BasicgeoModule extends KrollModule
{
	private String _purpose = "";
	public static final String MODULE_FULL_NAME = "becoding.basicGeo";
	public static boolean DEBUG = false;
	
	// You can define constants with @Kroll.constant, for example:
	// @Kroll.constant public static final String EXTERNAL_NAME = value;

	@Kroll.constant public static final int ACCURACY_COARSE = Criteria.ACCURACY_COARSE;
	@Kroll.constant public static final int ACCURACY_HIGH = Criteria.ACCURACY_HIGH;
	@Kroll.constant public static final int ACCURACY_FINE = Criteria.ACCURACY_FINE;
	@Kroll.constant public static final int ACCURACY_LOW = Criteria.ACCURACY_LOW;
	@Kroll.constant public static final int ACCURACY_MEDIUM = Criteria.ACCURACY_MEDIUM;
	@Kroll.constant public static final int NO_REQUIREMENT = Criteria.NO_REQUIREMENT;
	@Kroll.constant public static final int POWER_HIGH = Criteria.POWER_HIGH;
	@Kroll.constant public static final int POWER_LOW = Criteria.POWER_LOW;
	@Kroll.constant public static final int POWER_MEDIUM = Criteria.POWER_MEDIUM;
	
	public BasicgeoModule()
	{
		super();
	}

	@Kroll.method
	public void disableLogging()
	{
		DEBUG = false;
	}
	@Kroll.method
	public void enableLogging()
	{
		DEBUG = true;
	}
	
	private void logPurposeComment(){
		CommonHelpers.DebugLog("Purpose is not required by Android, is implemented for cross-platform capability");		
	}
	@Kroll.getProperty
	public String getPurpose(){
		logPurposeComment();
		return _purpose;
	}	

	@Kroll.setProperty
	public void purpose(String value){
		logPurposeComment();
		_purpose = value;
	}
	
	@Kroll.method
	public void setPurpose(String value){
		logPurposeComment();
		_purpose = value;
	}
}

