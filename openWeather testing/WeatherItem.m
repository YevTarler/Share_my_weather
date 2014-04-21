//
//  WeatherItem.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "WeatherItem.h"

@implementation WeatherItem

// maping the json. all json propertys u can get from API:
+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"date": @"dt",
             @"locationName": @"name",
             @"humidity": @"main.humidity",
             @"temperature": @"main.temp",
             @"tempHigh": @"main.temp_max",
             @"tempLow": @"main.temp_min",
             @"sunrise": @"sys.sunrise",
             @"sunset": @"sys.sunset",
             @"conditionDescription": @"weather.description",
             @"condition": @"weather.main",
             @"icon": @"weather.icon",
             @"windBearing": @"wind.deg",
             @"windSpeed": @"wind.speed"
             };
}

-(instancetype) initWithLocation: (NSString*) locationName temperature: (NSString*) temp icon:(NSString*) icon condition: (NSString*) condition date:(NSString*) date {
    self = [super init];
    if (self) {
        _locationName = locationName;
        _temperature = temp;
        _icon = icon;
        _condition = condition;
        _date = [self stringFromUnixTime:date];
    }
    return self;
}


//make an object 
+ (instancetype)weatherItemWithDictionary:(NSDictionary *)dictionary {
    WeatherItem *weatherItem = nil;
    if (dictionary) {
        weatherItem = [WeatherItem new];
        NSDictionary *keyMapping = [self JSONKeyPathsByPropertyKey];
        for (NSString *key in keyMapping) {
            
            NSString* value = keyMapping[key];
            id jsonValue = dictionary[value];
            if (jsonValue)
            {
                [WeatherItem setValue:value forKey:keyMapping[key]];
            }
        }
    }
    return weatherItem;
}

-(NSString*) stringFromUnixTime: (NSString *) unixTimeStamp {

    float num = [unixTimeStamp floatValue];
    NSTimeInterval _interval=num;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
    [_formatter setLocale:[NSLocale currentLocale]];
    //[_formatter setDateFormat:@"dd.MM.yyyy"];
    [_formatter setDateFormat:@"dd.MM.yyyy hh:mm"];
    NSString *dateUnix=[_formatter stringFromDate:date];
    return dateUnix;
    

}

-(NSString *)description {
    return [NSString stringWithFormat:@"Time: %@, City: %@, Temperature: %@, Condition: %@",self.date,self.locationName,self.temperature,self.condition];
}
-(NSString*) fahrenheitToCelsius {
    float celsius = (5.0/9.0) * ([self.temperature floatValue]-32);
    return [NSString stringWithFormat:@"%.01f",celsius];
}
@end
