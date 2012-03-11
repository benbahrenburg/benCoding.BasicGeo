/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoGeocoderProxy.h"
#import "TiUtils.h"
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
- (NSDictionary *)buildLocation:(CLPlacemark *)placemark
{
    
    NSDictionary *workingRegion = [NSDictionary dictionaryWithObjectsAndKeys:
                                NUMDOUBLE(((CLRegion *)[placemark region]).center.latitude),@"lat",NUMDOUBLE(((CLRegion *)[placemark region]).center.longitude),@"lng",NUMDOUBLE(((CLRegion *)[placemark region]).radius),@"radius",((CLRegion *)[placemark region]).identifier,@"identifier",
                                nil]; 
    
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                           [placemark addressDictionary],@"addressDictionary",
                           [placemark ISOcountryCode],@"ISOcountryCode",
                           [placemark country],@"country",
						   [placemark postalCode],@"postalCode",
                           [placemark administrativeArea],@"administrativeArea",
                           [placemark subAdministrativeArea],@"subAdministrativeArea",
                           [placemark locality],@"locality",
                           [placemark subLocality],@"subLocality",
                           [placemark thoroughfare],@"thoroughfare",
                           [placemark subThoroughfare],@"subThoroughfare",
                           workingRegion, @"region",
                           [NSNumber numberWithDouble:placemark.location.coordinate.latitude],@"latitude",
                           [NSNumber numberWithDouble:placemark.location.coordinate.longitude],@"longitude",
                          [NSNumber numberWithLongLong:(long long)([placemark.location.timestamp timeIntervalSince1970] * 1000)],@"timestamp",
                           nil];
    return data;
}

-(void)forwardGeocoder:(id)args
{
	ENSURE_ARG_COUNT(args,2);
    NSString* address = [TiUtils stringValue:[args objectAtIndex:0]];
	KrollCallback *callback = [args objectAtIndex:1];
	ENSURE_TYPE(callback,KrollCallback);
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geocoder geocodeAddressString:address completionHandler:^(NSArray* placemarks, NSError* error){
       
        if(placemarks && placemarks.count > 0)
        {
            NSMutableArray *placeData = [[[NSMutableArray alloc] init] autorelease];
            NSUInteger placesCount = [placemarks count];
            for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                [placeData addObject:[self buildLocation:[placemarks objectAtIndex:iLoop]]];
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
    
    CLLocation *findLocation = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    
    [geocoder reverseGeocodeLocation:findLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(placemarks && placemarks.count > 0)
        {
            NSMutableArray* placeData = [[[NSMutableArray alloc] init] autorelease];
            NSUInteger placesCount = [placemarks count];
            for (int iLoop = 0; iLoop < placesCount; iLoop++) {
                [placeData addObject:[self buildLocation:[placemarks objectAtIndex:iLoop]]];
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
