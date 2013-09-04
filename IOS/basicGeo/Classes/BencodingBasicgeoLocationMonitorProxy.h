/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import "DKLocationManager.h"
#import "TiUtils.h"
@interface BencodingBasicgeoLocationMonitorProxy : TiProxy {
@private
    NSTimer* locationTimeoutTimer;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_6_0
    CLActivityType activityType;
    BOOL pauseLocationUpdateAutomatically;
#endif
}
@property(strong, nonatomic) DKLocationManager* locationManager;
@end
