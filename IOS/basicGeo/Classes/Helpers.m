/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "Helpers.h"

@implementation Helpers

- (void) disabledLocationServiceMessage
{
    if ([CLLocationManager locationServicesEnabled]== NO) 
    {
        //NOTE: this is from Apple example from LocateMe and it works well. the developer can still check for the
        //property and do this message themselves before calling geo. But if they don't, we at least do it for them.
        NSString *title = NSLocalizedString(@"Location Services Disabled",@"Location Services Disabled Alert Title");
        NSString *msg = NSLocalizedString(@"You currently have all location services for this device disabled. If you proceed, you will be asked to confirm whether location services should be reenabled.",@"Location Services Disabled Alert Message");
        NSString *ok = NSLocalizedString(@"OK",@"Location Services Disabled Alert OK Button");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
        [servicesDisabledAlert show];
        [servicesDisabledAlert release];
        
    }  
}
- (NSDictionary *)buildFromPlaceLocation:(CLPlacemark *)placemark
{
    
    NSDictionary *workingRegion = [NSDictionary dictionaryWithObjectsAndKeys:
                                   NUMDOUBLE(((CLRegion *)[placemark region]).center.latitude),@"lat",NUMDOUBLE(((CLRegion *)[placemark region]).center.longitude),@"lng",NUMDOUBLE(((CLRegion *)[placemark region]).radius),@"radius",((CLRegion *)[placemark region]).identifier,@"identifier",
                                   nil]; 
    
    //    NSLog(@"administrativeArea: %@", [placemark administrativeArea]);
    //    NSLog(@"countryCode: %@", [placemark ISOcountryCode]);
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          [placemark addressDictionary],@"addressDictionary",
                          [placemark ISOcountryCode],@"countryCode",
                          [placemark country],@"countryName",
                          [placemark postalCode],@"postalCode",
                          [placemark administrativeArea],@"administrativeArea",
                          [placemark subAdministrativeArea],@"subAdministrativeArea",
                          [placemark locality],@"locality",
                          [placemark subLocality],@"subLocality",
                          [placemark thoroughfare],@"thoroughfare",
                          [placemark subThoroughfare],@"subThoroughfare",
                          workingRegion, @"region",
                          [NSNumber numberWithDouble:placemark.location.coordinate.latitude],@"latitude",
                          [NSNumber numberWithDouble:placemark.location.coordinate.longitude],@"longitude",
                          [NSNumber numberWithLongLong:(long long)([placemark.location.timestamp timeIntervalSince1970] * 1000)],@"timestamp",
                          nil];
    return data;
}

-(NSDictionary*)locationDictionary:(CLLocation*)newLocation;
{
	if ([newLocation timestamp] == 0)
	{
		// this happens when the location object is essentially null (as in no location)
		return nil;
	}
    
	CLLocationCoordinate2D latlon = [newLocation coordinate];
    
    
	NSDictionary * data = [NSDictionary dictionaryWithObjectsAndKeys:
						   [NSNumber numberWithFloat:latlon.latitude],@"latitude",
						   [NSNumber numberWithFloat:latlon.longitude],@"longitude",
						   [NSNumber numberWithFloat:[newLocation altitude]],@"altitude",
						   [NSNumber numberWithFloat:[newLocation horizontalAccuracy]],@"accuracy",
						   [NSNumber numberWithFloat:[newLocation verticalAccuracy]],@"altitudeAccuracy",
						   [NSNumber numberWithFloat:[newLocation course]],@"heading",
						   [NSNumber numberWithFloat:[newLocation speed]],@"speed",
						   [NSNumber numberWithLongLong:(long long)([[newLocation timestamp] timeIntervalSince1970] * 1000)],@"timestamp",
						   nil];
	return data;
}
@end
