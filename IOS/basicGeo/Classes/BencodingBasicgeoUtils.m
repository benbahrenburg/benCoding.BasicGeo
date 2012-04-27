/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoUtils.h"
#import "TiUtils.h"
@implementation utils

-(BOOL) allowBackgrounding
{
    UIDevice* device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)] &&
        [device isMultitaskingSupported]) {
        backgroundSupported=YES;
    }
    //[device release];
    return backgroundSupported;
}   

-(BOOL) significantLocationChangeMonitoringAvailable
{
    
    BOOL isSupported = NO;
    
    if ([CLLocationManager significantLocationChangeMonitoringAvailable])
    {
        isSupported = YES;
    }
    //This can call this to let them know if this feature is supported
    return isSupported;
} 
@end
