//
//  imageTakenViewController.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/23/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FXBlurView.h"
#import <Accelerate/Accelerate.h>

@interface imageTakenViewController : UIViewController
@property (nonatomic,strong) UIImage *imageTaken;
@property (nonatomic, weak) IBOutlet FXBlurView *blurView;

@end
