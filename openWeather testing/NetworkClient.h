//
//  NetworkClient.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LocationManager.h"
#import "WeatherItem.h"

@interface NetworkClient : NSObject
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic,strong) WeatherItem *item; //better use block

+ (NetworkClient *)sharedInstance;
// adding a block
- (void)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate completion:(void(^)(NSDictionary *data, NSError *error))completion ;
- (void) fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(void(^)(NSDictionary *data, NSError *error))completion ;
- (void)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(void(^)(NSDictionary *data, NSError *error))completion ;


@end
