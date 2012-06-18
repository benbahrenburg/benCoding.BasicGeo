/**
 * benCoding.basicGeo Project
 * Copyright (c) 2009-2012 by Ben Bahrenburg. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "BencodingBasicgeoTelephonyProxy.h"
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
@implementation BencodingBasicgeoTelephonyProxy

-(NSString*) mobileCountryCode:(id)args
{

#if TARGET_IPHONE_SIMULATOR

    return @"NA";
    
#else
    
    CTTelephonyNetworkInfo *networkInfo = [[[CTTelephonyNetworkInfo alloc] init] autorelease];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];

    NSString* carrierISO = [carrier mobileCountryCode];

    NSLog(@"Carrier ISO %@", carrierISO);
    
	return carrierISO;

#endif
}

@end
