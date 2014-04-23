//
//  MJViewController.h
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <stdlib.h>
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

@interface MJRootViewController : UIViewController
{
    NSMutableArray *allImages;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}
@property (nonatomic, strong) NSMutableArray* images;

- (void)uploadImage:(NSData *)imageData;
- (void)setUpImages:(NSArray *)images;
//- (void)buttonTouched:(id)sender;

@end
