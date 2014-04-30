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
        _uploaderDescription = @"No description given";
        if (![desc isEqualToString: kDescriptionPlaceHolder]) {
            _uploaderDescription = desc;
        }
        _uploaderName = @"Anonymous";
        if (![name isEqualToString:@""]) {
            _uploaderName =name;
        }
        _uploaderImage = [[UIImage alloc] init];
        _uploaderImage = image;
    }
    return self;
}


@end
