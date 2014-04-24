//
//  YEVViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/22/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

extern NSInteger const YevTransitionStyleGoUp;
extern NSInteger const YevTransitionStyleGoDown;
extern NSInteger const YevTransitionStyleGoLeft;
extern NSInteger const YevTransitionStyleGoRight;

#import <Foundation/Foundation.h>

@interface BouncePresentTransition : NSObject <UIViewControllerAnimatedTransitioning>

-(instancetype) initWithDirection: (NSInteger) direction;
@end
