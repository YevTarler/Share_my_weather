//
//  WeatherUploadDetailViewController.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/28/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeatherUploadDetailViewController : UIViewController<UIScrollViewDelegate>

@property (nonatomic,strong) UIImage* image;

- (IBAction)actionMenu:(id)sender;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;
@property (retain, nonatomic) IBOutlet UIImageView *imageView;
@property (retain, nonatomic) IBOutlet UIButton *btnMain;


@end
