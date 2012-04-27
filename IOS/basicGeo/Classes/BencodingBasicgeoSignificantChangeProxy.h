/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */
#import "TiProxy.h"
#import <CoreLocation/CoreLocation.h>
@interface BencodingBasicgeoSignificantChangeProxy : TiProxy< CLLocationManagerDelegate > {
    CLLocationManager *locationManager;
    NSString *purpose;
    double timeFilter;
}

@end
