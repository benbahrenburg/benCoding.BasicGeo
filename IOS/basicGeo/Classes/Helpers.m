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
    
    //NSLog(@"administrativeArea: %@", [placemark administrativeArea]);
    //NSLog(@"latitude: %f", placemark.location.coordinate.latitude);
    //NSLog(@"longitude: %f", placemark.location.coordinate.longitude);

    //NSLog(@"latitude as number: %@", [NSNumber numberWithDouble:placemark.location.coordinate.latitude]);
    //NSLog(@"longitude as number: %@", [NSNumber numberWithDouble:placemark.location.coordinate.longitude]);
    
    NSMutableDictionary *data = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:placemark.location.coordinate.latitude],@"latitude",
                                 [NSNumber numberWithDouble:placemark.location.coordinate.longitude],@"longitude",
                                 nil];
    
    if([placemark addressDictionary]!=nil)
    {
        [data setObject:[placemark addressDictionary] forKey:@"addressDictionary"];
    }
    if([placemark ISOcountryCode]!=nil)
    {
        [data setObject:[placemark ISOcountryCode] forKey:@"countryCode"];
    }
    if([placemark country]!=nil)
    {
        [data setObject:[placemark country] forKey:@"countryName"];
    }
    if([placemark postalCode]!=nil)
    {
        [data setObject:[placemark postalCode] forKey:@"postalCode"];
    }
    if([placemark administrativeArea]!=nil)
    {
        [data setObject:[placemark administrativeArea] forKey:@"administrativeArea"];
    }
    if([placemark subAdministrativeArea]!=nil)
    {
        [data setObject:[placemark subAdministrativeArea] forKey:@"subAdministrativeArea"];
    }
    if([placemark locality]!=nil)
    {
        [data setObject:[placemark locality] forKey:@"locality"];
    }
    if([placemark subLocality]!=nil)
    {
        [data setObject:[placemark subLocality] forKey:@"subLocality"];
    }
    if([placemark thoroughfare]!=nil)
    {
        [data setObject:[placemark thoroughfare] forKey:@"thoroughfare"];
    }
    if([placemark subThoroughfare]!=nil)
    {
        [data setObject:[placemark subThoroughfare] forKey:@"subThoroughfare"];
    }
    
    [data setObject:[NSNumber numberWithLongLong:(long long)([placemark.location.timestamp timeIntervalSince1970] * 1000)] forKey:@"timestamp"];
 
    if(workingRegion!=nil)
    {
        [data setObject:workingRegion forKey:@"region"];
    }
    
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
