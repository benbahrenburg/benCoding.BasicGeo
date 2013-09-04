/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoLocationMonitorProxy.h"
#import "Helpers.h"
@implementation BencodingBasicgeoLocationMonitorProxy
@synthesize locationManager;

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
    
    //keep the proxy from being collected
    [self rememberSelf];
    
    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
    float timerInterval = [TiUtils floatValue:[self valueForUndefinedKey:@"timerInterval"]def:-1];
    
    if(self.locationManager==nil)
    {
        self.locationManager = [[DKLocationManager alloc] initWithRepeatFlag:YES];
    }

    if (![TiUtils isIOS6OrGreater]) {
        //Set the purpose
        [self.locationManager setPurpose:purpose];
    }
    
    //Set accuracy
    [self.locationManager setAccuracy:accuracy];
    
    //Set distance filter
    [self.locationManager setDistanceFilter:distanceFilter];
    
    if ([TiUtils isIOS6OrGreater]) {
        [self.locationManager setPausesLocationUpdatesAutomatically:pauseLocationUpdateAutomatically];
        [self.locationManager setActivityType:NUMINT(activityType)];
    }
    
    float staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
  
    __weak __typeof(&*self)weakSelf = self;
    
    weakSelf.locationManager.locationUpdatedBlock = ^(CLLocation * location) {
    
        BencodingBasicgeoLocationMonitorProxy* s_self = weakSelf;
        
        //Determine of the data is stale
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        
        
        NSDictionary *todict = [helpers locationDictionary:location];
        
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               todict,@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < staleLimit)),@"stale",
                               nil];
        [s_self triggerListner:@"change" withEvents:event];
        
    };
    
    weakSelf.locationManager.locationErrorBlock = ^(NSError * error) {
        
        BencodingBasicgeoLocationMonitorProxy* s_self = weakSelf;
        
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        [s_self triggerListner:@"error" withEvents:errEvent];
        
    };
    
    if(locationTimeoutTimer!=nil){
        [locationTimeoutTimer invalidate];
        locationTimeoutTimer = nil;
    }
    

    [locationManager startLocationManager];
    
    NSDictionary *startEvent = [NSDictionary dictionaryWithObjectsAndKeys:NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"start"])
	{
        [self fireEvent:@"start" withObject:startEvent];
    }        

    _Counter = 0; // Reset count
    if(timerInterval > 1){
        locationTimeoutTimer = [NSTimer scheduledTimerWithTimeInterval:[[NSNumber numberWithFloat:timerInterval] doubleValue]
                                                                 target:weakSelf
                                                               selector:@selector(timerElapsed)
                                                               userInfo:nil
                                                                repeats:YES];
    }
    
}

- (void) stopMonitoring:(id)args
{
    if(self.locationManager!=nil)
    {
         [self.locationManager stopLocationManager];
    }
    
    NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
						   NUMBOOL(YES),@"success",nil];
    
	if ([self _hasListeners:@"stop"])
	{
        [self fireEvent:@"stop" withObject:event];
    }

    if(locationTimeoutTimer!=nil){
        [locationTimeoutTimer invalidate];
        locationTimeoutTimer = nil;
    }
    
    _Counter = 0; // Reset count
    
    [self forgetSelf]; //Allow for the proxy to be cleaned up
}

-(void)shutdownLocationManager
{
    
	if (self.locationManager == nil) {
		return;
	}
    
    [self.locationManager stopLocationManager];
    
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
        TiThreadPerformOnMainThread(^{[locationManager setActivityType:NUMINT(activityType)];}, NO);
    }
    
}
-(void)_destroy
{	
	// Make sure to release the callback objects
    [self shutdownLocationManager];
	[super _destroy];
}

@end
