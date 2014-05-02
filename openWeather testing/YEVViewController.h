//
//  YEVViewController.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationManager.h"
#import "NetworkClient.h"

@interface YEVViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIViewControllerTransitioningDelegate> //2

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *hiloLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (strong, nonatomic) IBOutlet UIView *headerView;

@property (nonatomic,strong) CLLocation *location;
@end
