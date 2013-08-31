/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoSignificantChangeProxy.h"
#import "BencodingBasicgeoModule.h"
#import "TiApp.h"
#import "Helpers.h"
@implementation BencodingBasicgeoSignificantChangeProxy

@synthesize locationManager;

-(void)_configure
{
    
    if ([TiUtils isIOS6OrGreater]) {
        // activity Type by default
        activityType = CLActivityTypeOther;
        
        // pauseLocationupdateAutomatically by default NO
        pauseLocationUpdateAutomatically  = NO;
        
    }
    
	[super _configure];
}

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
            purpose = [BencodingBasicgeoModule reason];
            
        }
        
        if (purpose==nil)
        { 
            NSLog(@"[ERROR] Starting in iOS 3.2, you must set the benCoding.SignificantChange.purpose property to indicate the purpose of using Location services for your application");
        }
        else
        {
            #if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
                [locationManager setPurpose:purpose];
            #endif
        }
        
        if ([TiUtils isIOS6OrGreater]) {
            [locationManager setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];
            [locationManager setActivityType:CLActivityTypeOther];
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

    
    Helpers * helpers = [[Helpers alloc] init];
    
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
        Helpers * helpers = [[Helpers alloc] init];
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


-(NSNumber*)pauseLocationUpdateAutomatically
{
	return NUMBOOL(pauseLocationUpdateAutomatically);
}

-(void)setPauseLocationUpdateAutomatically:(id)value
{
	if ([TiUtils isIOS6OrGreater]) {
        pauseLocationUpdateAutomatically = [TiUtils boolValue:value];
        TiThreadPerformOnMainThread(^{[locationManager setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];}, NO);
    }
}

-(NSNumber*)activityType
{
	return NUMINT(activityType);
}

-(void)setActivityType:(NSNumber *)value
{
    if ([TiUtils isIOS6OrGreater]) {
        activityType = [TiUtils intValue:value];
        TiThreadPerformOnMainThread(^{[locationManager setActivityType:activityType];}, NO);
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

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
    if ([self _hasListeners:@"locationupdatepaused"])
	{
		[self fireEvent:@"locationupdatepaused" withObject:nil];
	}
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    if ([self _hasListeners:@"locationupdateresumed"])
	{
		[self fireEvent:@"locationupdateresumed" withObject:nil];
	}
}

#endif
-(void)shutdownLocationManager
{

	if (locationManager == nil) {
		return;
	}
    
    [locationManager stopMonitoringSignificantLocationChanges];
    locationManager.delegate = nil;
    
}
-(void)_destroy
{
	// This method is called from the dealloc method and is good place to
	// release any objects and memory that have been allocated for the proxy.
   [self shutdownLocationManager];
   [super _destroy];
}

@end
