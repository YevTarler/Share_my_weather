//
//  LocationManager.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * const kLocationDidChangeNotificationKey; //will be used to signal location changes.

@interface LocationManager : NSObject


@property (nonatomic, readonly)    CLLocation *currentLocation;
@property (nonatomic, readonly) BOOL       isMonitoringLocation;

+ (instancetype)sharedManager;

- (void)startMonitoringLocationChanges;
- (void)stopMonitoringLocationChanges;


@end
