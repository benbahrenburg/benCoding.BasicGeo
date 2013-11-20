/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoCurrentGeolocationProxy.h"
#import "BencodingBasicgeoModule.h"
#import "Helpers.h"

@implementation BencodingBasicgeoCurrentGeolocationProxy

CLLocationManager *_locationManager;

-(void)_configure
{
    _isStarted = NO;
    
	[super _configure];
}

-(void)setCacheTime:(id)unused
{
    NSLog(@"setCacheTime is not used by iOS and is inplace to support a cross-platform API");
}
-(void)setCacheDistance:(id)unused
{
    NSLog(@"setCacheDistance is not used by iOS and is inplace to support a cross-platform API");
}
-(void)setCache:(id)unused
{
    NSLog(@"setCache is not used by iOS and is inplace to support a cross-platform API");
}
-(void)setGeoLocale:(id)unused
{
    NSLog(@"setGeoLocale is not used by iOS and is inplace to support a cross-platform API");
}

-(void) findPlace:(CLLocation*)location
{
    Helpers * helpers = [[Helpers alloc] init];
    CLLocationCoordinate2D latlon = [location coordinate];
    CLLocation *findLocation = [[CLLocation alloc] initWithLatitude:latlon.latitude longitude:latlon.longitude];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:findLocation
                   completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0)
        {
            NSMutableArray* placeData = [[NSMutableArray alloc] init];
            NSUInteger placesCount = [placemarks count];
            for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                [placeData addObject:[helpers buildFromPlaceLocation:[placemarks objectAtIndex:iLoop]]];
            }
            
            if (placeCallback!=nil){
                NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:placesCount],@"placeCount",
                                         placeData,@"places",
                                         NUMBOOL(YES),@"success",
                                         nil];
                
                [self _fireEventToListener:@"place"
                                withObject:eventOk listener:placeCallback thisObject:nil];
                placeCallback = nil;
            }
        }
        else
        {
            if (placeCallback!=nil){
                NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [error localizedDescription],@"error",
                                          NUMBOOL(NO),@"success",nil];
                [self _fireEventToListener:@"place"
                                withObject:eventErr listener:placeCallback thisObject:nil];
                placeCallback = nil;
            }
        }
    }];
    
}
-(void)getCurrentPlace:(id)callback
{
    ENSURE_SINGLE_ARG(callback,KrollCallback);
    ENSURE_UI_THREAD(getCurrentPlace,callback);
    placeCallback = callback;
    
    _staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
  
    Helpers * helpers = [[Helpers alloc] init];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }

    //Check that we have at least iOS 5
    if(NSClassFromString(@"UIReferenceLibraryViewController")==nil)
    {
        if (placeCallback){
            NSDictionary* noCompatErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"iOS 5 or greater is required for this feature",@"error",
                                         NUMBOOL(NO),@"success",nil];
            
            [self _fireEventToListener:@"place"
                            withObject:noCompatErr listener:placeCallback thisObject:nil];
            placeCallback = nil;
        }
        
        return;
    }
    
    [self startFindingLocation];
}



-(NSDictionary*)locationToDict:(CLLocation*)location
{
    Helpers * helpers = [[Helpers alloc] init];
    return [helpers locationDictionary:location];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didUpdateToLocation");
    if(positionCallback!=nil){
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        [self _fireEventToListener:@"error"
                        withObject:errEvent listener:positionCallback thisObject:nil];
        positionCallback = nil;
    }
    
    [self shutdownFindingLocation];
    
    if (placeCallback!=nil){
        NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [error localizedDescription],@"error",
                                  NUMBOOL(NO),@"success",nil];
        [self _fireEventToListener:@"place"
                        withObject:eventErr listener:placeCallback thisObject:nil];
        placeCallback = nil;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if(positionCallback!=nil){
        NSDate* eventDate = newLocation.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self locationToDict:newLocation],@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < _staleLimit)),@"stale",
                               nil];
        
        [self _fireEventToListener:@"location"
                        withObject:event listener:positionCallback thisObject:nil];
        positionCallback = nil;
    }
    
    [self shutdownFindingLocation];
    
    if (placeCallback!=nil){
        [self findPlace:newLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{    
	
    CLLocation *location = [locations lastObject];
    
    if(positionCallback!=nil){
        NSDate* eventDate = location.timestamp;
        NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
        NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:
                               [self locationToDict:location],@"coords",
                               NUMBOOL(YES),@"success",
                               NUMBOOL((abs(howRecent) < _staleLimit)),@"stale",
                               nil];
        
        [self _fireEventToListener:@"location"
                        withObject:event listener:positionCallback thisObject:nil];
        positionCallback = nil;
    }
    
    [self shutdownFindingLocation];
    
    if (placeCallback!=nil){
        [self findPlace:location];
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
	}
	return _locationManager;
}

-(void) shutdownFindingLocation
{
   if(_locationManager!=nil)
   {
        [[self tempLocationManager] stopUpdatingLocation];
   }
    _isStarted = NO;
}

-(void)startFindingLocation
{
    if(_isStarted){
        return;
    }
    
    [self.tempLocationManager startUpdatingLocation];
}

-(void)getCurrentPosition:(id)callback
{
	ENSURE_SINGLE_ARG(callback,KrollCallback);
    ENSURE_UI_THREAD(getCurrentPosition,callback);
    positionCallback = callback;
    _staleLimit = [TiUtils floatValue:[self valueForUndefinedKey:@"staleLimit"]def:15.0];
    [self startFindingLocation];
}

-(void)_destroy
{
    [self shutdownFindingLocation];
	positionCallback = nil;
    placeCallback = nil;
	[super _destroy];
}

@end
