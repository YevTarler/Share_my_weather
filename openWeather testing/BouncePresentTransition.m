//
//  YEVViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/22/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//


#import "BouncePresentTransition.h"

NSInteger const YevTransitionStyleGoUp = 1;
NSInteger const YevTransitionStyleGoRight = 2;
NSInteger const YevTransitionStyleGoDown = 3;
NSInteger const YevTransitionStyleGoLeft = 4;


@interface BouncePresentTransition(){
    NSInteger _chosenStyle;
    CGRect _frameForStyle;
    CGFloat _dx;
    CGFloat _dy;
}
@end
@implementation BouncePresentTransition

-(instancetype)initWithDirection:(NSInteger) direction {
    self = [super init];
    if (self) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        switch(direction){
            case YevTransitionStyleGoUp:
                _dx = 0;
                _dy = screenBounds.size.height;
                break;
            case YevTransitionStyleGoRight:
                _dx = -screenBounds.size.width;
                _dy = 0;
                break;
            case YevTransitionStyleGoDown:
                _dx = 0;
                _dy = -screenBounds.size.height;
                break;
            default:
                _dx = screenBounds.size.width;
                _dy = 0;
        }
        
    }
    return self;
}
-(id)init {
    return [self initWithDirection:4];

}

- (NSTimeInterval)transitionDuration:(id <UIViewControllerContextTransitioning>)transitionContext
{
  return 0.7;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext
{
  // obtain state from context
  UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
  UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
  CGRect finalFrame = [transitionContext finalFrameForViewController:toViewController];
  
  // obtain the container view
  UIView *containerView = [transitionContext containerView];
  
  // set initial state
  toViewController.view.frame = CGRectOffset(finalFrame, _dx, _dy);
  
  // add the view
  [containerView addSubview:toViewController.view];
  
  // animate
  [UIView animateWithDuration:[self transitionDuration:transitionContext]
                        delay:0
       usingSpringWithDamping:0.5
          initialSpringVelocity:0.0
                      options:UIViewAnimationOptionCurveLinear
                   animations:^{
                     fromViewController.view.alpha = 0.5;
                     toViewController.view.frame = finalFrame;
                   } completion:^(BOOL finished) {
                     fromViewController.view.alpha = 1.0;
                     // inform the context of completion
                     [transitionContext completeTransition:YES];
                   }];
}


@end
