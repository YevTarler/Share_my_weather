//
//  YEVViewController.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface YEVViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate,UIViewControllerTransitioningDelegate> //2

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) IBOutlet UIView *headerView;


@end
