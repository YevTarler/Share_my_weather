//
//  WeatherPhotoUploadStore.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/25/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherPhotoUpload.h"

@interface WeatherPhotoUploadStore : NSObject

@property(nonatomic,strong,readonly) NSMutableArray* weatherUploadData;

+ (WeatherPhotoUploadStore *)sharedWeatherUploadsStore;
-(void) addWeatherUpload:(WeatherPhotoUpload*) weatherUpload;
-(NSArray *) getAllWeatherUploads;
-(WeatherPhotoUpload *) getWeatherUploadAtIndex:(NSInteger) index;
-(void) removeWeatherUploadAtIndex:(NSInteger) index;

@end
