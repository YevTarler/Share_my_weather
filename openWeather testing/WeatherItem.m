//
//  WeatherItem.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "WeatherItem.h"

@implementation WeatherItem

+ (NSDictionary *)imageMap {
    // 1
    static NSDictionary *_imageMap = nil;
    if (! _imageMap) {
        // 2
        _imageMap = @{
                      @"01d" : @"weather-clear",
                      @"02d" : @"weather-few",
                      @"03d" : @"weather-few",
                      @"04d" : @"weather-broken",
                      @"09d" : @"weather-shower",
                      @"10d" : @"weather-rain",
                      @"11d" : @"weather-tstorm",
                      @"13d" : @"weather-snow",
                      @"50d" : @"weather-mist",
                      @"01n" : @"weather-moon",
                      @"02n" : @"weather-few-night",
                      @"03n" : @"weather-few-night",
                      @"04n" : @"weather-broken",
                      @"09n" : @"weather-shower",
                      @"10n" : @"weather-rain-night",
                      @"11n" : @"weather-tstorm",
                      @"13n" : @"weather-snow",
                      @"50n" : @"weather-mist",
                      };
    }
    return _imageMap;
}

-(instancetype) initWithLocation: (NSString*) locationName temperature: (NSString*) temp icon:(NSString*) icon condition: (NSString*) condition date:(NSString*) date {
    self = [super init];
    if (self) {
        _locationName = locationName;
        
        _temperature = [self celsiusStringFromFahrenheitString:temp];
        _icon = icon;
        _condition = condition;
        _date = [self stringFromUnixTime:date];
    }
    return self;
}

-(NSString *)tempHigh {
    return [self celsiusStringFromFahrenheitString:_tempHigh];
}
-(NSString *)tempLow {
    return [self celsiusStringFromFahrenheitString:_tempLow];
}
-(NSString*) celsiusStringFromFahrenheitString:(NSString*)faren {
    
    float celsius = (5.0/9.0) * ([faren floatValue]-32);
    int tempRound = lroundf(celsius);
    return [NSString stringWithFormat:@"%d°",tempRound];
}

-(NSDate*) stringFromUnixTime: (NSString *) unixTimeStamp {

    float num = [unixTimeStamp floatValue];
    NSTimeInterval _interval=num;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:_interval];
    return date;
//    NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
//    [_formatter setLocale:[NSLocale currentLocale]];
//    //[_formatter setDateFormat:@"dd.MM.yyyy"];
//    [_formatter setDateFormat:@"h a"];
//    NSString *dateUnix=[_formatter stringFromDate:date];
//    return dateUnix;
    

}


-(NSString *)description {
    return [NSString stringWithFormat:@"Time: %@, City: %@, Temperature: %@, Condition: %@",self.date,self.locationName,self.temperature,self.condition];
}
-(NSString*) fahrenheitToCelsius {
    float celsius = (5.0/9.0) * ([self.temperature floatValue]-32);
    return [NSString stringWithFormat:@"%.01f",celsius];
}
@end
