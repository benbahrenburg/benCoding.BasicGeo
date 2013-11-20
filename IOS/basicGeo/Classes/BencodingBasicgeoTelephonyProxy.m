/**
 * benCoding.basicGeo Project
 * Copyright (c) 2013 by Ben Bahrenburg. All Rights Reserved.
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
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];

    NSString* mobileCountryCode = [carrier mobileCountryCode];

    //NSLog(@"Carrier ISO %@", carrierISO);
    
	return mobileCountryCode;

#endif
}

-(NSString*) isoCountryCode:(id)args
{
    
#if TARGET_IPHONE_SIMULATOR
    
    return @"-";
    
#else
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    NSString* carrierISO = [carrier isoCountryCode];
    
    //NSLog(@"Carrier ISO %@", carrierISO);
    
	return carrierISO;
    
#endif
}

@end
