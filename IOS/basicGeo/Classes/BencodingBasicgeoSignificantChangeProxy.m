/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoSignificantChangeProxy.h"
#import "TiApp.h"
#import "Helpers.h"
@implementation BencodingBasicgeoSignificantChangeProxy

@synthesize locationManager;

-(NSNumber*)isSupported:(id)args
{
    BOOL isSupported = NO;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}
-(NSNumber*)wasLaunchedByGeo:(id)args
{
    BOOL hasGeoLauchedOption = NO;
    if ([[[TiApp app] launchOptions] objectForKey:UIApplicationLaunchOptionsLocationKey])
    {
        hasGeoLauchedOption=YES;
    }

    return NUMBOOL(hasGeoLauchedOption);
}

-(void)initLocationManager 
{
    if (locationManager==nil)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; 
        NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
        
        if (purpose==nil)
        { 
            NSLog(@"[ERROR] Starting in iOS 3.2, you must set the benCoding.SignificantChange.purpose property to indicate the purpose of using Location services for your application");
        }
        else
        {
            [locationManager setPurpose:purpose];
        }         
    }
     
}

- (void) startSignificantChange:(id)args
{
    //We need to be on the UI thread, or the Change event wont fire
    ENSURE_UI_THREAD(startSignificantChange,args);
    
    if(![CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"Signicant Location Monitoring Not Available",@"error",
                               NUMBOOL(NO),@"success",nil];
        
        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }
        return;
    }

    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    } 
    
    //If we need to startup location manager we do it here
    if (locationManager==nil)
    {
        [self initLocationManager]; 
    }
    
    [locationManager startMonitoringSignificantLocationChanges];
    
    NSDictionary *startEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"start"])
	{
        [self fireEvent:@"start" withObject:startEvent];
    }    
    
}

- (void) stopSignificantChange:(id)args
{
    if (locationManager !=nil)
    {
        [locationManager stopMonitoringSignificantLocationChanges];
    }
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
						   NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"stop"])
	{
        [self fireEvent:@"stop" withObject:event];
    }
        
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    @try
    {
        Helpers * helpers = [[[Helpers alloc] init] autorelease];
        //Determine of the data is stale
        NSDate* eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        float staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
        
        NSDictionary *todict = [helpers locationDictionary:newLocation];
        
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               todict,@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < staleLimit)),@"stale",
                               nil];
        
        if ([self _hasListeners:@"change"])
        {
            [self fireEvent:@"change" withObject:event];
        }  
    }
    @catch (NSException* ex)
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:ex.reason,@"error",
                               ex.name, @"code",
                               NUMBOOL(NO),@"success",nil];

        if ([self _hasListeners:@"error"])
        {
            [self fireEvent:@"error" withObject:errEvent];
        }        
    }  
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

    NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
						   NUMINT([error code]), @"code",
						   NUMBOOL(NO),@"success",nil];
 
	if ([self _hasListeners:@"error"])
	{
		[self fireEvent:@"error" withObject:errEvent];
	}
}

//Force the calibration header to turn off
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

-(void)shutdownLocationManager
{

	if (locationManager == nil) {
		return;
	}
    
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager.delegate = nil;
    
	RELEASE_TO_NIL_AUTORELEASE(locationManager);

}
-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the proxy.
   [self shutdownLocationManager];
   [super _destroy];
}

@end
