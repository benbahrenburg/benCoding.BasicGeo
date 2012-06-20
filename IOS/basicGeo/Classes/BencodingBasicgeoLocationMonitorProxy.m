/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoLocationMonitorProxy.h"
#import "Helpers.h"
@implementation BencodingBasicgeoLocationMonitorProxy
@synthesize locationManager;


- (void) startMonitoring:(id)args
{
    //We need to be on the UI thread, or the Change event wont fire
    ENSURE_UI_THREAD(startMonitoring,args);
    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
    
    if(locationManager==nil)
    {
        locationManager = [[DKLocationManager alloc] init];
    }

    //Set the purpose
    [locationManager setPurpose:purpose];
    //Set accuracy
    [locationManager setAccuracy:accuracy];
    //Set distance filter
    [locationManager setDistanceFilter:distanceFilter];
    
    locationManager.locationUpdatedBlock = ^(CLLocation * location) {
    
        //Determine of the data is stale
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        float staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
        
        NSDictionary *todict = [helpers locationDictionary:location];
        
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               todict,@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < staleLimit)),@"stale",
                               nil];
        
        if ([self _hasListeners:@"change"])
        {
            [self fireEvent:@"change" withObject:event];
        } 
        
    };
    
    locationManager.locationErrorBlock = ^(NSError * error) {
        
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }        
        
    };
    
    [locationManager startLocationManager];
    
    NSDictionary *startEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"start"])
	{
        [self fireEvent:@"start" withObject:startEvent];
    }        
    
}

- (void) stopMonitoring:(id)args
{
    if(locationManager!=nil)
    {
         [locationManager stopLocationManager];
    }
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
						   NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"stop"])
	{
        [self fireEvent:@"stop" withObject:event];
    }    
}

-(void)shutdownLocationManager
{
    
	if (locationManager == nil) {
		return;
	}
    
    [locationManager stopLocationManager];
    
	RELEASE_TO_NIL_AUTORELEASE(locationManager);
    
}
-(void)_destroy
{	
	// Make sure to release the callback objects
    [self shutdownLocationManager];
	[super _destroy];
}

@end
