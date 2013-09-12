/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoLocationMonitorProxy.h"
#import "Helpers.h"
#import "BencodingBasicgeoModule.h"
@implementation BencodingBasicgeoLocationMonitorProxy

CLLocationManager * _locationManager;
int _Counter = 0;

-(void)_configure
{
    locationTimeoutTimer = nil;
    
    if ([TiUtils isIOS6OrGreater]) {
        // activity Type by default
        activityType = CLActivityTypeOther;
        
        // pauseLocationupdateAutomatically by default NO
        pauseLocationUpdateAutomatically  = NO;
        
    }
    
	[super _configure]; 
}

-(void)locationChangedEvent:(CLLocation*)location
{
 
    if([self _hasListeners:@"change"]){
        //Determine of the data is stale
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        Helpers * helpers = [[Helpers alloc] init];
        NSDictionary *todict = [helpers locationDictionary:location];
        
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               todict,@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < _staleLimit)),@"stale",
                               nil];
        [self fireEvent:@"change" withObject:event];
    }

}
-(NSDictionary*)locationToDict:(CLLocation*)location
{
    Helpers * helpers = [[Helpers alloc] init];
    return [helpers locationDictionary:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if([self _hasListeners:@"error"])
    {
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        [self fireEvent:@"error" withObject:errEvent];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation");
    [self locationChangedEvent : newLocation];
    
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
	NSLog(@"didUpdateToLocations");
    CLLocation *location = [locations lastObject];
    [self locationChangedEvent : location];
}

-(void)shutdownLocationManager
{
    if (_locationManager!=nil){
        [_locationManager stopUpdatingHeading];
        _locationManager = nil;
    }
    
    if(locationTimeoutTimer!=nil){
        [locationTimeoutTimer invalidate];
        locationTimeoutTimer = nil;
    }
}
-(CLLocationManager*)tempLocationManager
{
	if (_locationManager!=nil)
	{
		// if we have an instance, just use it
		return _locationManager;
	}
	
	if (_locationManager == nil) {
		_locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.pausesLocationUpdatesAutomatically = pauseLocationUpdateAutomatically;
        
        NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
        if (purpose==nil){
            purpose = [BencodingBasicgeoModule reason];
        }
        if ([TiUtils isIOS6OrGreater]) {
            if(purpose!=nil){
                if ([_locationManager respondsToSelector:@selector(setPurpose)]) {
                    [self.tempLocationManager setPurpose:purpose];
                }
            }
        }else{
            if (purpose==nil){
                NSLog(@"[ERROR] Starting in iOS 3.2, you must set the purpose property to indicate the purpose of using Location services for your application");
            }
            else{
                [_locationManager setPurpose:purpose];
            }
        }
        if ([TiUtils isIOS6OrGreater]) {
            [_locationManager setActivityType:NUMINT(activityType)];
        }
	}
	return _locationManager;
}

- (void) triggerListner:(NSString *)name withEvents:(NSDictionary *)events
{
    if ([self _hasListeners:name])
    {
        [self fireEvent:name withObject:events];
    }
}

- (void)timerElapsed
{
    if(_Counter > 30000){
        _Counter = 0;
    }
    _Counter += 1;
    NSDictionary *timerEvent = [NSDictionary dictionaryWithObjectsAndKeys:@"timerFired",@"action",
                                NUMINT(_Counter), @"intervalCount",
                                NUMBOOL(YES),@"success",nil];
    
    [self triggerListner:@"timerFired" withEvents:timerEvent];
}

- (void) startMonitoring:(id)args
{
    //We need to be on the UI thread, or the Change event wont fire
    ENSURE_UI_THREAD(startMonitoring,args);

    // pauseLocationupdateAutomatically by default NO
    pauseLocationUpdateAutomatically  = NO;
    
    Helpers * helpers = [[Helpers alloc] init];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    float timerInterval = [TiUtils floatValue:[self valueForUndefinedKey:@"timerInterval"]def:-1];
    _staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
    
    if(locationTimeoutTimer!=nil){
        [locationTimeoutTimer invalidate];
        locationTimeoutTimer = nil;
    }
    

    [[self tempLocationManager] startUpdatingLocation];
    
    NSDictionary *startEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"start"])
	{
        [self fireEvent:@"start" withObject:startEvent];
    }        

    _Counter = 0; // Reset count
    if(timerInterval > 1){
        locationTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:
                                [[NSNumber numberWithFloat:timerInterval] doubleValue]
                                                                 target:self
                                                               selector:@selector(timerElapsed)
                                                               userInfo:nil
                                                                repeats:YES];
    }
    
}

- (void) stopMonitoring:(id)args
{
    ENSURE_UI_THREAD(stopMonitoring,args);
    
    [self shutdownLocationManager];
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
						   NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"stop"])
	{
        [self fireEvent:@"stop" withObject:event];
    }
    
    _Counter = 0; // Reset count
    
    [self forgetSelf]; //Allow for the proxy to be cleaned up
}

-(NSNumber*)pauseLocationUpdateAutomatically
{
	return NUMBOOL(pauseLocationUpdateAutomatically);
}

-(void)setPauseLocationUpdateAutomatically:(id)value
{
	if ([TiUtils isIOS6OrGreater]) {
        pauseLocationUpdateAutomatically = [TiUtils boolValue:value];
        TiThreadPerformOnMainThread(^{
            [[self tempLocationManager] setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];
        }, NO);
    }
}

-(NSNumber*)activityType
{
	return NUMINT(activityType);
}

-(void)setDistanceFilter:(NSNumber *)value
{
	ENSURE_UI_THREAD(setDistanceFilter,value);
	// don't prematurely start it
	if ([self tempLocationManager]!=nil)
	{
		[[self tempLocationManager] setDistanceFilter:[TiUtils doubleValue:value]];
	}
}
-(void)setAccuracy:(NSNumber *)value
{
	ENSURE_UI_THREAD(setAccuracy,value);
	// don't prematurely start it
	if ([self tempLocationManager]!=nil)
	{
		[[self tempLocationManager] setDesiredAccuracy:[TiUtils doubleValue:value]];
	}
}
-(void)setActivityType:(NSNumber *)value
{
    if ([TiUtils isIOS6OrGreater]) {
        activityType = [TiUtils intValue:value];
        TiThreadPerformOnMainThread(^{
            [[self tempLocationManager] setActivityType:NUMINT(activityType)];
        }, NO);
    }
    
}
-(void)_destroy
{	
	// Make sure to release the callback objects
    [self shutdownLocationManager];
	[super _destroy];
}

@end
