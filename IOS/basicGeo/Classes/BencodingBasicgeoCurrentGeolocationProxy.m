/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoCurrentGeolocationProxy.h"
#import "BencodingBasicgeoModule.h"
#import "Helpers.h"

@implementation BencodingBasicgeoCurrentGeolocationProxy

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


-(void)getCurrentPlace:(id)callback
{
	ENSURE_SINGLE_ARG(callback,KrollCallback);
	ENSURE_UI_THREAD(getCurrentPlace,callback);
    KrollCallback *methodCallback = callback;
    

    Helpers * helpers = [[[Helpers alloc] init] autorelease];

    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }

    //Check that we have at least iOS 5
    if(NSClassFromString(@"UIReferenceLibraryViewController")==nil)
    {
        if (methodCallback){
            NSDictionary* noCompatErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                      @"iOS 5 or greater is required for this feature",@"error",
                                      NUMBOOL(NO),@"success",nil];  
            
            [self _fireEventToListener:@"place" 
                            withObject:noCompatErr listener:methodCallback thisObject:nil];
        }
        
        return;
    }

    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];

    if (purpose==nil)
    {
        purpose = [BencodingBasicgeoModule reason];
        
    }

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

                if (methodCallback){                
                    NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [NSNumber numberWithInt:placesCount],@"placeCount",
                                             placeData,@"places",
                                             NUMBOOL(YES),@"success",
                                             nil];
                    
                    [self _fireEventToListener:@"place" 
                                    withObject:eventOk listener:methodCallback thisObject:nil];
                }     
            }
            else
            {
                if (methodCallback){
                    NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                              [error localizedDescription],@"error",
                                              NUMBOOL(NO),@"success",nil];  
                    [self _fireEventToListener:@"place" 
                                    withObject:eventErr listener:methodCallback thisObject:nil];
                }
            }
        }];
    };
    
    locationManager.locationErrorBlock = ^(NSError * error) {
        
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        if (methodCallback){ 
            [self _fireEventToListener:@"place" 
                            withObject:errEvent listener:methodCallback thisObject:nil];           
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

    KrollCallback *methodCallback = callback;
    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    double distanceFilter = [TiUtils doubleValue:[self valueForUndefinedKey:@"distanceFilter"]def:kCLDistanceFilterNone];
    double accuracy = [TiUtils doubleValue:[self valueForUndefinedKey:@"accuracy"]def:kCLLocationAccuracyThreeKilometers];
    NSString * purpose = [TiUtils stringValue:[self valueForUndefinedKey:@"purpose"]];
 
    if (purpose==nil)
    {
        purpose = [BencodingBasicgeoModule reason];
        
    }
    
    DKLocationManager * locationManager = [[DKLocationManager alloc]
                                            initWithParameters:distanceFilter 
                                           desiredAccuracy:accuracy 
                                           purpose:purpose];
    
    locationManager.locationUpdatedBlock = ^(CLLocation * location) {
 
        if (methodCallback){                
            
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
                            withObject:event listener:methodCallback thisObject:nil];
        } 
        //NSLog(@"Location change to: %@", location);
        [locationManager release];
        
    };
    
    locationManager.locationErrorBlock = ^(NSError * error) {
  
        NSDictionary *errEvent = [NSDictionary dictionaryWithObjectsAndKeys:[error localizedDescription],@"error",
                                  NUMINT([error code]), @"code",
                                  NUMBOOL(NO),@"success",nil];
        
        if (methodCallback){ 
            [self _fireEventToListener:@"location" 
                            withObject:errEvent listener:methodCallback thisObject:nil];           
        }
       
        NSLog(@"Error: %@", error);
        [locationManager release];
        
    };
    
    [locationManager findCurrentCoordinates];
}

-(void)_destroy
{	
	// Make sure to release the callback objects
	[super _destroy];
}

@end
