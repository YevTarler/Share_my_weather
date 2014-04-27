//
//  WeatherPhotoUpload.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/25/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "WeatherPhotoUpload.h"
#import "preUploadViewController.h"

@interface WeatherPhotoUpload ()

@end

@implementation WeatherPhotoUpload


-(instancetype) initWithName: (NSString*)name Image:(UIImage*)image ImageDescription:(NSString*)desc {
    self = [super init];
    if(self) {
        _uploaderDescription = @"none";
        if (![desc isEqualToString: kDescriptionPlaceHolder]) {
            _uploaderDescription = desc;
        }
        _uploaderDescription = [NSString stringWithString:desc];
        _uploaderName = [NSString stringWithString:name];
        _uploaderImage = [[UIImage alloc] init];
        _uploaderImage = image;
    }
    return self;
}


@end
