/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoHelpersProxy.h"
#import "TiUtils.h"
@implementation BencodingBasicgeoHelpersProxy

- (NSNumber *) distanceBetweenInMeters:(id)args
{   	
    //Make sure we have all of the points we need
    ENSURE_ARG_COUNT(args,4);
    //Convert the parameters into lat and lon pairs
	CGFloat lat1 = [TiUtils floatValue:[args objectAtIndex:0]];
	CGFloat lon1 = [TiUtils floatValue:[args objectAtIndex:1]];
	CGFloat lat2 = [TiUtils floatValue:[args objectAtIndex:2]];
	CGFloat lon2 = [TiUtils floatValue:[args objectAtIndex:3]];   
    //Create two location objects so we can compare
    CLLocation *location1 = [[[CLLocation alloc] initWithLatitude:lat1 longitude:lon1] autorelease];
    CLLocation *location2 = [[[CLLocation alloc] initWithLatitude:lat2 longitude:lon2] autorelease];
    //Find the distance between in meters
    double distance = [location1 distanceFromLocation:location2];    
    //NSLog ( @"distance: %f", distance );
    //Convert to number so that Titanium will proxy everything for us
    NSNumber *results = [NSNumber numberWithDouble:distance]; 
    return results;
}

CGFloat DegreesToRadians(CGFloat degrees) {
	return degrees * M_PI / 180;
}

CGFloat RadiansToDegrees(CGFloat radians)
{
	return radians * 180 / M_PI;
}

- (NSNumber*)bearingInDegrees:(id)args
{
    //Make sure we have all of the points we need
    ENSURE_ARG_COUNT(args,4);
	CGFloat lat1 = [TiUtils floatValue:[args objectAtIndex:0]];
	CGFloat lon1 = [TiUtils floatValue:[args objectAtIndex:1]];
	CGFloat lat2 = [TiUtils floatValue:[args objectAtIndex:2]];
	CGFloat lon2 = [TiUtils floatValue:[args objectAtIndex:3]]; 
	float deltalng = lon2 - lon1;
	double y = sin(deltalng) * cos(lat2);
	double x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltalng);
	double bearing = atan2(y, x) + 2 * M_PI;
	float bearingDegrees = RadiansToDegrees(bearing);
	bearingDegrees = (int)bearingDegrees % 360;
	return [NSNumber numberWithDouble:bearingDegrees];
}

@end
