//
//  DKLocationManager.h
//  DiscoKit
//
//  Created by Keith Pitt on 13/07/11.
//  Copyright 2011 Mostly Disco. All rights reserved.
//

//
//  Code modified from https://github.com/keithpitt/DKLocationManager
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void (^DKLocationManagerCallback)(CLLocation *);
typedef void (^DKLocationManagerErrorCallback)(NSError *);

@interface DKLocationManager : NSObject <CLLocationManagerDelegate>{
@private
    NSString * _purpose;
    BOOL _oneTimeOnly;
}

@property (nonatomic, copy) DKLocationManagerCallback locationUpdatedBlock;
@property (nonatomic, copy) DKLocationManagerErrorCallback locationErrorBlock;

@property (nonatomic, strong) CLLocationManager * locationManager;
@property (nonatomic, strong) CLLocation * currentLocation;

- (id)initWithParameters:(CLLocationDistance)distanceFilter desiredAccuracy:(CLLocationAccuracy)desiredAccuracy purpose:(NSString*)purpose;

- (void)findCurrentCoordinates;
- (void)startLocationManager;
- (void)stopLocationManager;
- (void)setAccuracy:(CLLocationAccuracy)value;
- (void)setPurpose:(NSString *)reason;
- (void)setDistanceFilter:(CLLocationDistance)value;
- (void)setPausesLocationUpdatesAutomatically:(BOOL)value;
- (void)setActivityType:(NSNumber *)value;
@end