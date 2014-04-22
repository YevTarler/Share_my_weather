//
//  WeatherItem.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeatherItem : NSObject

@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *humidity;
@property (nonatomic, strong) NSString *temperature;
@property (nonatomic, strong) NSString *tempHigh;
@property (nonatomic, strong) NSString *tempLow;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSDate *sunrise;
@property (nonatomic, strong) NSDate *sunset;
@property (nonatomic, strong) NSString *conditionDescription;
@property (nonatomic, strong) NSString *condition;
@property (nonatomic, strong) NSNumber *windBearing;
@property (nonatomic, strong) NSNumber *windSpeed;
@property (nonatomic, strong) NSString *icon;

-(instancetype) initWithLocation: (NSString*) locationName temperature: (NSString*) temp icon:(NSString*) icon condition: (NSString*) condition date:(NSString*) date;
-(NSString*) fahrenheitToCelsius;
+ (NSDictionary *)imageMap;
@end

//need 