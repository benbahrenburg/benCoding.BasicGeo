package bencoding.basicgeo;
import android.location.Location;

public class LocationResults {
	public final String providerName;
	public final Location location;

   public LocationResults(String providerName, Location location) {
      this.providerName = providerName;
      this.location = location;
   }
}
