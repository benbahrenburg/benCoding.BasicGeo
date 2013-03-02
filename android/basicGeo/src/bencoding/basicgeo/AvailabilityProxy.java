package bencoding.basicgeo;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;


@Kroll.proxy(creatableInModule  = BasicgeoModule.class)
public class AvailabilityProxy extends KrollProxy  {

	public AvailabilityProxy()
	{
		super();		

	}
	@Kroll.getProperty
	public boolean reverseGeoSupported(){
		return CommonHelpers.reverseGeoSupported();
	}
	
	@Kroll.getProperty
	public boolean locationServicesEnabled(){
		return CommonHelpers.hasProviders();
	}
	@Kroll.getProperty
	public boolean regionMonitoringAvailable(){
		return false;
	}
	@Kroll.getProperty
	public boolean regionMonitoringEnabled(){
		return false;
	}		
	@Kroll.getProperty
	public boolean locationServicesAuthorization(){
		return CommonHelpers.hasProviders();
	}	
}
