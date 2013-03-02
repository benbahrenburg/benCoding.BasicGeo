/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoAvailabilityProxy.h"
#import "TiUtils.h"
@implementation BencodingBasicgeoAvailabilityProxy

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_2
MAKE_SYSTEM_PROP(AUTHORIZATION_UNKNOWN, kCLAuthorizationStatusNotDetermined);
MAKE_SYSTEM_PROP(AUTHORIZATION_AUTHORIZED, kCLAuthorizationStatusAuthorized);
MAKE_SYSTEM_PROP(AUTHORIZATION_DENIED, kCLAuthorizationStatusDenied);
MAKE_SYSTEM_PROP(AUTHORIZATION_RESTRICTED, kCLAuthorizationStatusRestricted);
#else
// We only need auth unknown, because that's all the system will return.
MAKE_SYSTEM_PROP(AUTHORIZATION_UNKNOWN, 0);
#endif

-(NSNumber*)isReverseGeoSupported:(id)args
{
    [self reverseGeoSupported];
}

-(NSNumber*)reverseGeoSupported
{
    BOOL isSupported = NO;
    if(NSClassFromString(@"UIReferenceLibraryViewController"))
    {
        isSupported=YES;
    }
    
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}

-(NSNumber*)allowBackgrounding:(id)args
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] &&
        [device isMultitaskingSupported]) {
        backgroundSupported=YES;
    }
    return NUMBOOL(backgroundSupported);
}
-(NSNumber*)significantLocationChangeMonitoringAvailable:(id)args
{
    BOOL isSupported = NO;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}

-(NSNumber*)headingAvailable:(id)args
{
    BOOL isSupported = NO;
    
    if ([CLLocationManager headingAvailable])
    {
        isSupported=true;
    }
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}


-(NSNumber*) locationServicesEnabled
{
    
    BOOL isSupported = NO;
    
    if ([CLLocationManager locationServicesEnabled])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
     return NUMBOOL(isSupported);
} 

-(NSNumber*) regionMonitoringAvailable
{
    
    BOOL isSupported = NO;
    
    if ([CLLocationManager regionMonitoringAvailable])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
     return NUMBOOL(isSupported);
} 


-(NSNumber*)locationServicesAuthorization
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_2
	if ([TiUtils isIOS4_2OrGreater]) {
		return NUMINT([CLLocationManager authorizationStatus]);
	}
#endif
	return [self AUTHORIZATION_UNKNOWN];
}

-(NSNumber*) regionMonitoringEnabled
{
    
    BOOL isSupported = NO;
    
    if ([CLLocationManager regionMonitoringEnabled])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
    return NUMBOOL(isSupported);
}

@end
