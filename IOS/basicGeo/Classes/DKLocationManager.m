//
//  DKLocationManager.m
//  DiscoKit
//
//  Created by Keith Pitt on 13/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

//
//  Code modified from https://github.com/keithpitt/DKLocationManager
//

#import "DKLocationManager.h"
#import "BencodingBasicgeoModule.h"
#import "TiUtils.h"
@implementation DKLocationManager

@synthesize locationManager, currentLocation, locationUpdatedBlock,
locationErrorBlock;

- (id)init {
    
    if ((self = [super init])) {
        
        // Setup the location manager 
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
        locationManager.distanceFilter = 100; // or whatever
        if ([TiUtils isIOS6OrGreater]) {
            [locationManager setPausesLocationUpdatesAutomatically:NO];
            [locationManager setActivityType:CLActivityTypeOther];
        }
        _oneTimeOnly=YES;        
    }
    
    return self;
    
}

- (id)initWithParameters:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy purpose:(NSString*)purpose{
    
    if ((self = [self init])) {
    
        if(purpose !=nil)
        {
            _purpose = purpose;
        }

        if (_purpose==nil)
        {
            purpose = [BencodingBasicgeoModule reason];
            
        }
        
        if (_purpose==nil)
        { 
            NSLog(@"[ERROR] Starting in iOS 3.2, you must set the purpose property to indicate the purpose of using Location services for your application");
        }
        else
        {
            #if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
                [self.locationManager setPurpose:_purpose];
            #endif
        }
        
        [self.locationManager setDesiredAccuracy:desiredAccuracy];
        [self.locationManager setDistanceFilter:distanceFilter];
    }
    
    return self;
    
}
- (void)setActivityType:(NSNumber *)value
{
	if (self.locationManager!=nil)
	{
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
            [self.locationManager setActivityType:value];
        #endif
	}
}
- (void)setPausesLocationUpdatesAutomatically:(BOOL)value
{
	// don't prematurely start it
	if (self.locationManager!=nil)
	{
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
            [self.locationManager setPausesLocationUpdatesAutomatically:value];
        #endif
	}
}
-(void)setAccuracy:(CLLocationAccuracy)value
{
	// don't prematurely start it
	if (self.locationManager!=nil)
	{
		[self.locationManager setDesiredAccuracy:value];
	}
}
-(void)setDistanceFilter:(CLLocationDistance)value
{
	// don't prematurely start it
	if (self.locationManager!=nil)
	{
		[self.locationManager setDistanceFilter:value];
	}
}
-(void)setPurpose:(NSString *)reason
{
	_purpose = reason;
	if (self.locationManager!=nil)
	{
        #if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
            [self.locationManager setPurpose:_purpose];
        #endif
	}
}
- (void)startLocationManager {
    _oneTimeOnly=NO;
    [self.locationManager startUpdatingLocation];
}

- (void)stopLocationManager {
     _oneTimeOnly=YES;
    [self.locationManager stopUpdatingLocation]; 
}

- (void)findCurrentCoordinates {
    _oneTimeOnly=YES;
    [self.locationManager startUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
        
    // Test that the horizontal accuracy does not indicate an invalid measurement
    if (newLocation.horizontalAccuracy < 0) return;
    
    // Store the new location
    self.currentLocation = newLocation;
    
    // Call the location updated block
    if (self.locationUpdatedBlock)
        self.locationUpdatedBlock(newLocation);
    
    if(_oneTimeOnly)
    {
        // IMPORTANT!!! Minimize power usage by stopping the location manager as soon as possible.
        [self.locationManager stopUpdatingLocation];        
    }
    
}

//Force the calibration header to turn off
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager
{
    return NO;
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    // Call the location error block
    if (self.locationErrorBlock) {
        self.locationErrorBlock(error);
    }
    
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{

}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
    
}

#endif
- (void)dealloc {
    
    // Releation the location updated block
    if (locationUpdatedBlock) {
        Block_release(locationUpdatedBlock);
    }
    
    // Releation the location error block
    if (locationErrorBlock) {
        Block_release(locationErrorBlock);
    }
    
    if(self.locationManager!=nil)
    {
        [self.locationManager stopUpdatingLocation]; 
        // Release the location manager
        self.locationManager = nil;        
    }
    
    [super dealloc];
    
}

@end