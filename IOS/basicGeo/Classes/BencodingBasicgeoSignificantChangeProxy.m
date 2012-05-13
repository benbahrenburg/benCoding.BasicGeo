/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoSignificantChangeProxy.h"
#import "BencodingBasicgeoUtils.h"
#import "TiApp.h"
@implementation BencodingBasicgeoSignificantChangeProxy

-(NSNumber*)isSupported:(id)args
{
    utils * helpers = [[[utils alloc] init] autorelease];    
    BOOL isSupported = [helpers significantLocationChangeMonitoringAvailable];
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

-(NSString*)purpose
{
	return purpose;
}

-(void)setPurpose:(NSString *)reason
{
	ENSURE_UI_THREAD(setPurpose,reason);
	RELEASE_TO_NIL(purpose);
	purpose = [reason retain];
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
-(void)initLocationManager 
{
    if (nil == locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self; 
        
        if (purpose==nil)
        { 
            NSLog(@"[ERROR] Starting in iOS 3.2, you must set the benCoding.SignificantChange.purpose property to indicate the purpose of using Location services for your application");
        }
        else
        {
            [locationManager setPurpose:purpose];
        }
        
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
     
}
- (void) startSignificantChange:(id)args
{
    //We need to make sure this is on the UI thread in order to have
    //the purpose and time filters applied correctly
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
    
    [self initLocationManager];    
    
    [locationManager startMonitoringSignificantLocationChanges];
    
    NSDictionary *okEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"start"])
	{
        [self fireEvent:@"start" withObject:okEvent];
    }    
    
}

- (void) stopSignificantChange:(id)args
{
    [locationManager stopMonitoringSignificantLocationChanges];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
						   NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"stop"])
	{
        [self fireEvent:@"stop" withObject:event];
    }
        
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    NSDictionary *todict = [self locationDictionary:newLocation];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                           todict,@"coords",
                           NUMBOOL(YES),@"success",
                           nil];
    
    if ([self _hasListeners:@"change"])
    {
        [self fireEvent:@"change" withObject:event];
    }  
    
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{

    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
						   NUMINT([error code]), @"code",
						   NUMBOOL(NO),@"success",nil];
    
	if ([self _hasListeners:@"error"])
	{
		[self fireEvent:@"error" withObject:event];
	}
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
    RELEASE_TO_NIL(purpose);
	[super _destroy];
}

@end
