package bencoding.basicgeo;

import org.appcelerator.kroll.KrollProxy;
import org.appcelerator.kroll.annotations.Kroll;
import org.appcelerator.kroll.common.Log;
import org.appcelerator.titanium.util.TiConvert;
import android.location.Location;

@Kroll.proxy(creatableInModule = BasicgeoModule.class)
public class HelpersProxy extends KrollProxy  {
	// Standard Debugging variables
	private static final String LCAT = "BasicgeoModule";
	public HelpersProxy() {
		super();
	}

	@Kroll.method
	public float distanceBetweenInMeters(Object[] args)
	{
		final int kArgLat1 = 0;
		final int kArgLng1 = 1;
		final int kArgLat2 = 2;
		final int kArgLng2 = 3;
		final int kArgCount = 4;
		float distance = 0;
		
		// Validate correct number of arguments
		if (args.length < kArgCount) {
			throw new IllegalArgumentException("Requires 4 arguments: latitude1, longitude1, latitude2, and longitude2");
		}
		
		Location location1 = new Location("");
		Location location2 = new Location("");
		try{
		// Use the TiConvert methods to get the values from the arguments
		double lat1 = (args[kArgLat1] != null) ? TiConvert.toDouble(args[kArgLat1]) : 0;
		double lng1 = (args[kArgLng1] != null) ? TiConvert.toDouble(args[kArgLng1]) : 0;
		location1.setLatitude(lat1);
		location1.setLongitude(lng1);
		
		double lat2 = (args[kArgLat2] != null) ? TiConvert.toDouble(args[kArgLat2]) : 0;
		double lng2 = (args[kArgLng2] != null) ? TiConvert.toDouble(args[kArgLng2]) : 0;		
		location2.setLatitude(lat2);
		location2.setLongitude(lng2);
		//Calculate the distance between the two locations
		distance = location1.distanceTo(location2);
		
        } catch (Exception e) {
            Log.e(LCAT, "[REVERSEGEO] Geocoder error", e);
        } finally {
        	location1=null;
        	location2=null;
        }
		return distance; 		
	}
}
