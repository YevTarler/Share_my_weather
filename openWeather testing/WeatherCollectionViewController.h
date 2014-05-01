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

@interface WeatherCollectionViewController : UIViewController
{
    NSMutableArray *allWeatherUploads;
    
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
}
@property (nonatomic, strong) NSMutableArray* images;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic) BOOL showAll;

- (void)uploadImage:(NSData *)imageData;
- (void)setUpImages:(NSArray *)images;
//- (void)buttonTouched:(id)sender;
- (IBAction)unwindToPictureCollectionviewController:(UIStoryboardSegue *)unwindSegue;
- (UIViewController *)viewControllerForUnwindSegueAction:(SEL)action fromViewController:(UIViewController *)fromViewController withSender:(id)sender;
- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier;
@end
