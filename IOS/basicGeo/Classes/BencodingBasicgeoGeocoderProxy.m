/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoGeocoderProxy.h"
#import "BencodingBasicgeoModule.h"
#import "TiUtils.h"
#import "Helpers.h"
@implementation BencodingBasicgeoGeocoderProxy
-(NSNumber*)isSupported:(id)args
{
    hasMinOSVersion=NO;
    if(NSClassFromString(@"UIReferenceLibraryViewController"))
    {
        hasMinOSVersion=YES;
    }
    
    //This can call this to let them know if this feature is supported
    return NUMBOOL(hasMinOSVersion);
}

-(void)forwardGeocoder:(id)args
{
    
	ENSURE_ARG_COUNT(args,2);
    NSString* address = [TiUtils stringValue:[args objectAtIndex:0]];
	KrollCallback *callback = [args objectAtIndex:1];
	ENSURE_TYPE(callback,KrollCallback);
    ENSURE_UI_THREAD(forwardGeocoder,args);
    
    Helpers * helpers = [[[Helpers alloc] init] autorelease];
    
    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }
    
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
       
        if(placemarks && placemarks.count > 0)
        {
            NSMutableArray *placeData = [[[NSMutableArray alloc] init] autorelease];
            NSUInteger placesCount = [placemarks count];
            for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                [placeData addObject:[helpers buildFromPlaceLocation:[placemarks objectAtIndex:iLoop]]];
            }    
            
            if (callback){                
                NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:placesCount],@"placeCount",
                                         placeData,@"places",
                                         NUMBOOL(YES),@"success",                                     
                                         nil];
                
                [self _fireEventToListener:@"completed" 
                                withObject:eventOk listener:callback thisObject:nil];
            }                 
            
        }
        else
        {
            if (callback){
                NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [error localizedDescription],@"error",
                                          NUMBOOL(NO),@"success",nil];  
                
                [self _fireEventToListener:@"completed" 
                                withObject:eventErr listener:callback thisObject:nil];
            }            
        }
    }];
    
}
-(void)reverseGeocoder:(id)args
{
    
	ENSURE_ARG_COUNT(args,3);
	CGFloat lat = [TiUtils floatValue:[args objectAtIndex:0]];
	CGFloat lon = [TiUtils floatValue:[args objectAtIndex:1]];
	KrollCallback *callback = [args objectAtIndex:2];
	ENSURE_TYPE(callback,KrollCallback);
    ENSURE_UI_THREAD(reverseGeocoder,args);
    

    Helpers * helpers = [[[Helpers alloc] init] autorelease];

    if ([CLLocationManager locationServicesEnabled]== NO)
    {
        [helpers disabledLocationServiceMessage];
        return;
    }

    CLLocation *findLocation = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];

    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geocoder reverseGeocodeLocation:findLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0)
        {
            NSMutableArray* placeData = [[[NSMutableArray alloc] init] autorelease];
            NSUInteger placesCount = [placemarks count];
            for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                [placeData addObject:[helpers buildFromPlaceLocation:[placemarks objectAtIndex:iLoop]]];
            }
            
            if (callback){                
                NSDictionary *eventOk = [NSDictionary dictionaryWithObjectsAndKeys:
                                         [NSNumber numberWithInt:placesCount],@"placeCount",
                                         placeData,@"places",
                                         NUMBOOL(YES),@"success",
                                         nil];

                [self _fireEventToListener:@"completed" 
                                withObject:eventOk listener:callback thisObject:nil];
            }     
        }
        else
        {
            if (callback){
                NSDictionary* eventErr = [NSDictionary dictionaryWithObjectsAndKeys:
                                          [error localizedDescription],@"error",
                                          NUMBOOL(NO),@"success",nil];  
                
                [self _fireEventToListener:@"completed" 
                                withObject:eventErr listener:callback thisObject:nil];
            }
        }
    }];   
    
}

@end
