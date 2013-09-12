/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiProxy.h"
#import <CoreLocation/CoreLocation.h>

@interface BencodingBasicgeoCurrentGeolocationProxy : TiProxy<CLLocationManagerDelegate> {
    @private
    BOOL _isStarted;
    KrollCallback *positionCallback;
    KrollCallback *placeCallback;
    float _staleLimit;
}


@end