//
//  WeatherPhotoUpload.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/25/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface WeatherPhotoUpload : NSObject
@property (nonatomic,strong,readonly) NSString *uploaderName;
@property (nonatomic,strong,readonly) NSString *uploaderDescription;
@property (nonatomic,strong,readonly) UIImage *uploaderImage;
@property (nonatomic,strong) NSString* uploaderLocationCity;
@property (nonatomic,strong) UIImage* thumbnail;
@property (nonatomic,strong) UIImage* mapThumbnail;
@property (nonatomic,strong) CLLocation *locationWherePictureTaken;

-(instancetype) initWithName: (NSString*)name Image:(UIImage*)image ImageDescription:(NSString*)desc;
@end
