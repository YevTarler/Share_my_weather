//
//  WeatherPhotoUploadStore.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/25/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "WeatherPhotoUploadStore.h"


@implementation WeatherPhotoUploadStore

+ (WeatherPhotoUploadStore *)sharedWeatherUploadsStore // shared "store"
{
    static WeatherPhotoUploadStore *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        //init woth the designated initializer
        
        _sharedInstance = [[self alloc] init]; //use designated init here !
    });
    
    return _sharedInstance;
}
-(id)init {
    
    if (self = [super init]){
        _weatherUploadData = [[NSMutableArray alloc]init];
    }
    return self;
}

-(void) addWeatherUpload:(WeatherPhotoUpload*) weatherUpload{
    [self.weatherUploadData addObject:weatherUpload];
}
-(void) pushWeatherUploadToBeginning:(WeatherPhotoUpload*)weatherUpload{
    [self.weatherUploadData insertObject:weatherUpload atIndex:0];
}
-(NSArray *) getAllWeatherUploads{
    return self.weatherUploadData;
}
-(WeatherPhotoUpload *) getWeatherUploadAtIndex:(NSInteger) index{
    return self.weatherUploadData[index];
    
}
-(void) removeWeatherUploadAtIndex:(NSInteger) index{
    [self.weatherUploadData removeObjectAtIndex:index];
}
-(void) removeAllObjects {
    [self.weatherUploadData removeAllObjects];
}
-(void) removeLastWeatherObject{
    [self.weatherUploadData removeLastObject];
}
@end
