//
//  YEVViewController.h
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YEVViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic,strong) UIImageView *blurredImageView;
//@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, assign) CGFloat screenHeight;
@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end
