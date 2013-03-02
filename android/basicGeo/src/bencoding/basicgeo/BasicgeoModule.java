/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

package bencoding.basicgeo;

import org.appcelerator.kroll.KrollModule;
import org.appcelerator.kroll.annotations.Kroll;

@Kroll.module(name="Basicgeo", id="bencoding.basicgeo")
public class BasicgeoModule extends KrollModule
{
	private String _purpose = "";
	public static final String MODULE_FULL_NAME = "becoding.basicGeo";

	// You can define constants with @Kroll.constant, for example:
	// @Kroll.constant public static final String EXTERNAL_NAME = value;
	
	public BasicgeoModule()
	{
		super();
	}

	@Kroll.method
	public void disableLogging()
	{
		CommonHelpers.UpdateWriteStatus(false);
	}
	@Kroll.method
	public void enableLogging()
	{
		CommonHelpers.UpdateWriteStatus(true);
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

