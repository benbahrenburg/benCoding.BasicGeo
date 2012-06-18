/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import <Foundation/Foundation.h>
#import "TiUtils.h"
#import <CoreLocation/CoreLocation.h>
@interface Helpers : NSObject

- (void) disabledLocationServiceMessage;
- (NSDictionary *)buildFromPlaceLocation:(CLPlacemark *)placemark;
- (NSDictionary*)locationDictionary:(CLLocation*)newLocation;

@end
