package bencoding.basicgeo;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import android.location.Criteria;

@Kroll.proxy(creatableInModule  = BasicgeoModule.class)
public class CriteriaProxy extends KrollProxy{
		
	private int _accuracy = Criteria.ACCURACY_COARSE;
	private boolean _useCache = false;
	private int _cacheDistance = 10;
	private long _cacheTime = 30000;
	private int _powerRequirement = Criteria.POWER_HIGH;
	private boolean _speedRequired = true;
	private int _verticalAccuracy = Criteria.ACCURACY_FINE;
	private boolean _costAllowed = true;
	boolean _bearingRequired = true;
	int _bearingAccuracy = Criteria.ACCURACY_COARSE;
	int _horizontalAccuracy = Criteria.ACCURACY_COARSE;	
	Criteria _criteria = null;
	
	public CriteriaProxy() {
		super();
		_criteria = new Criteria();
	}
	
	@Kroll.method @Kroll.getProperty
	public boolean getCostAllowed(){
		return _costAllowed;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setCostAllowed(boolean Value){
		_costAllowed = Value;
		_criteria.setCostAllowed(Value);
	}
	
	@Kroll.method @Kroll.setProperty
	public void setCacheTime(long Value){
		_cacheTime = Value;
	}

	@Kroll.method @Kroll.getProperty
	public long getCacheTime(){
		return _cacheTime ;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setCacheDistance(int Value){
		_cacheDistance = Value;
	}

	@Kroll.method @Kroll.getProperty
	public int getCacheDistance(){
		return _cacheDistance;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setVerticalAccuracy(int Value){
		_verticalAccuracy = Value;
		_criteria.setVerticalAccuracy(Value);
	}
	@Kroll.method @Kroll.getProperty
	public int getVerticalAccuracy(){
		return _verticalAccuracy;
	}
	@Kroll.method @Kroll.setProperty
	public void setUseCache(boolean Value){
		_useCache = Value;
	}
	@Kroll.method @Kroll.getProperty
	public boolean getUseCache(){
		return _useCache;
	}	
	@Kroll.method @Kroll.setProperty
	public void setSpeedRequired(boolean Value){
		_speedRequired = Value;
		_criteria.setSpeedRequired(Value);
	}
	@Kroll.method @Kroll.getProperty
	public boolean getSpeedRequired(){
		return _speedRequired;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setDistanceFilter(long Value){
		CommonHelpers.DebugLog("distanceFilter here is used for cross-platform compatibility. A distance of 0 will be used.");
	}
	@Kroll.method @Kroll.getProperty
	public long getDistanceFilter(){
		return 0;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setPowerRequirement(int Value){
		_powerRequirement = Value;
		_criteria.setPowerRequirement(Value);
	}
	@Kroll.method @Kroll.getProperty
	public int getPowerRequirement(){
		return _powerRequirement;
	}

	@Kroll.method @Kroll.getProperty
	public int getAccuracy(){
		return _accuracy;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setAccuracy(int Value){
		_accuracy = Value;
		_criteria.setAccuracy(Value);
	}
		
	@Kroll.method @Kroll.setProperty
	public void setBearingRequired(boolean Value){
		_bearingRequired = Value;
		_criteria.setBearingRequired(Value);
	}
	@Kroll.method @Kroll.getProperty
	public boolean getBearingRequired(){
		return _bearingRequired;
	}

	@Kroll.method @Kroll.setProperty
	public void setBearingAccuracy(int Value){
		_bearingAccuracy = Value;
		_criteria.setBearingAccuracy(Value);
	}
	@Kroll.method @Kroll.getProperty
	public int getBearingAccuracy(){
		return _bearingAccuracy;
	}
	
	@Kroll.method @Kroll.setProperty
	public void setHorizontalAccuracy(int Value){
		_horizontalAccuracy = Value;
		_criteria.setHorizontalAccuracy(Value);
	}
	@Kroll.method @Kroll.getProperty
	public int getHorizontalAccuracy(){
		return _horizontalAccuracy;
	}
	
	public Criteria getCriteria(){		
		return _criteria;
	}
}
