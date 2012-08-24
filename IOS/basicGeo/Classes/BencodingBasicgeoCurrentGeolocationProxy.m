/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoCurrentGeolocationProxy.h"
#import "Helpers.h"

@implementation BencodingBasicgeoCurrentGeolocationProxy


-(void)getCurrentPlace:(id)callback
{
	ENSURE_SINGLE_ARG(callback,KrollCallback);
	ENSURE_UI_THREAD(getCurrentPlace,callback);
    RELEASE_TO_NIL(placeCallback); 
    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
      
    placeCallback=[callback retain];
    
    //Check that we have at least iOS 5
    if(NSClassFromString(@"UIReferenceLibraryViewController")==nil)
    {
        if (placeCallback){
            NSDictionary* noCompatErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"iOS 5 or greater is required for this feature",@"error",
                                      NUMBOOL(NO),@"success",nil];  
            
            [self _fireEventToListener:@"place" 
                            withObject:noCompatErr listener:placeCallback thisObject:nil];
        }
        
        return;
    }
    
    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
    
    DKLocationManager * locationManager = [[DKLocationManager alloc] 
                                            initWithParameters:distanceFilter 
                                            desiredAccuracy:accuracy 
                                            purpose:purpose];
    
    locationManager.locationUpdatedBlock = ^(CLLocation * location) {
 
        CLLocationCoordinate2D latlon = [location coordinate];
        [locationManager release];
        CLLocation *findLocation = [[[CLLocation alloc] initWithLatitude:latlon.latitude longitude:latlon.longitude] autorelease];
        CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
        
        [geocoder reverseGeocodeLocation:findLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            if(placemarks && placemarks.count > 0)
            {
                NSMutableArray* placeData = [[[NSMutableArray alloc] init] autorelease];
                NSUInteger placesCount = [placemarks count];
                for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                    [placeData addObject:[helpers buildFromPlaceLocation:[placemarks objectAtIndex:iLoop]]];
                }
                
                if (placeCallback){                
                    
                    NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:placesCount],@"placeCount",
                                             placeData,@"places",
                                             NUMBOOL(YES),@"success",
                                             nil];
                    
                    [self _fireEventToListener:@"place" 
                                    withObject:eventOk listener:placeCallback thisObject:nil];
                }     
            }
            else
            {            
                if (placeCallback){
                    NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [error localizedDescription],@"error",
                                              NUMBOOL(NO),@"success",nil];  
                    
                    [self _fireEventToListener:@"place" 
                                    withObject:eventErr listener:placeCallback thisObject:nil];
                }
            }
        }];
    };
    
    locationManager.locationErrorBlock = ^(NSError * error) {
        
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if (placeCallback){ 
            [self _fireEventToListener:@"place" 
                            withObject:errEvent listener:locationCallback thisObject:nil];           
        }
        
        NSLog(@"Error: %@", error);
        [locationManager release];
    };
    
    [locationManager findCurrentCoordinates];
    
}
-(void)getCurrentPosition:(id)callback
{
	ENSURE_SINGLE_ARG(callback,KrollCallback);
	ENSURE_UI_THREAD(getCurrentPosition,callback);
	RELEASE_TO_NIL(locationCallback);   
    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    locationCallback=[callback retain];

    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
    
    DKLocationManager * locationManager = [[DKLocationManager alloc] 
                                            initWithParameters:distanceFilter 
                                           desiredAccuracy:accuracy 
                                           purpose:purpose];
    
    locationManager.locationUpdatedBlock = ^(CLLocation * location) {
 
        if (locationCallback){                
            
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
            
            [self _fireEventToListener:@"location" 
                            withObject:event listener:locationCallback thisObject:nil];
        } 
        //NSLog(@"Location change to: %@", location);
        [locationManager release];
        
    };
    
    locationManager.locationErrorBlock = ^(NSError * error) {
  
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if (locationCallback){ 
            [self _fireEventToListener:@"location" 
                            withObject:errEvent listener:locationCallback thisObject:nil];           
        }
       
        NSLog(@"Error: %@", error);
        [locationManager release];
        
    };
    
    [locationManager findCurrentCoordinates];
}

-(void)_destroy
{	
	// Make sure to release the callback objects
	RELEASE_TO_NIL(locationCallback);
    RELEASE_TO_NIL(placeCallback); 
	[super _destroy];
}

@end
