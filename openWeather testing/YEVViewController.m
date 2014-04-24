//
//  YEVViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "YEVViewController.h"
#import "LocationManager.h"
#import "NetworkClient.h"
#import "WeatherItem.h"
#import "MJRootViewController.h"

#import "BouncePresentTransition.h"
#import "FXBlurView.h"

#import <LMAlertView.h>
@interface YEVViewController ()
{
    NSString * city;
    NSString* temp;
 
}
@property (nonatomic,strong) NetworkClient *client;


@property (nonatomic,strong) NSMutableArray* hourlyWeather;
@property (nonatomic,strong) NSMutableArray* dailyWeather;
@property (nonatomic,strong) WeatherItem* currentWeather;

@property (weak, nonatomic) IBOutlet UILabel *temperatureLabel;
@property (weak, nonatomic) IBOutlet UILabel *hiloLabel;
@property (weak, nonatomic) IBOutlet UILabel *conditionsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@property (nonatomic,strong) CLLocation *location;

@property (nonatomic,strong) MJRootViewController *mjrvc;
@property (weak, nonatomic) IBOutlet FXBlurView *bluredView;



@end

@implementation YEVViewController 



- (void)viewDidLoad
{
    
    [super viewDidLoad];

    self.bluredView.blurRadius = 25;
    self.bluredView.alpha=0;
    //transition:
    self.modalPresentationStyle = UIModalPresentationCustom; //1
    
    
    self.hourlyWeather = [[NSMutableArray alloc]init];
    self.dailyWeather = [[NSMutableArray alloc]init];
    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView.image = background;

//    self.blurredImageView.alpha = 0;
//   // [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
//   // [self.view addSubview:self.blurredImageView];
//    
    self.tableView.backgroundColor = [UIColor clearColor];
//    [self.tableView setOpaque: NO];
    UIView *headerV = self.headerView;
    self.tableView.tableHeaderView = headerV;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
   // [self createCustomHeader];
    

    
    self.location = [[LocationManager sharedManager] currentLocation];
    //
    
    [self reloadData];
}

- (IBAction)swipedRight:(id)sender {
    //change transition ?
    if (_mjrvc == nil) { //user those if only so the use wont push it twice and more
        // UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
        _mjrvc = [self.storyboard instantiateViewControllerWithIdentifier:@"rootVC"];
        
    }
    _mjrvc.transitioningDelegate = self;
    [self presentViewController:_mjrvc animated:YES completion:nil];
}
#pragma mark - Custom animation delegate methods

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    return [[BouncePresentTransition alloc]initWithDirection:YevTransitionStyleGoLeft];
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

return [[BouncePresentTransition alloc]initWithDirection:YevTransitionStyleGoRight];}

-(void)didUpdateToLocation:(CLLocation *)newLocation
              fromLocation:(CLLocation *)oldLocation{
    NSLog(@"lat:%f long:%f",newLocation.coordinate.latitude,newLocation.coordinate.longitude);

    
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(UIView *)headerView {
    if (!_headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"initialHeader" owner:self options:nil];
    }
    return _headerView;
}
                    
- (void)reloadData
{
    NSLog(@"check 123");
    self.client = [NetworkClient sharedInstance];

    
    [self.client fetchCurrentConditionsForLocation:self.location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
            self.currentWeather = [[WeatherItem alloc]initWithLocation:data[@"name"] temperature:data[@"main"][@"temp"]  icon:data[@"weather"][0][@"icon"] condition:data[@"weather"][0][@"main"] date:data[@"dt"]] ;
            
            
            
            self.currentWeather.tempLow = data[@"main"][@"temp_min"];
             self.currentWeather.tempHigh = data[@"main"][@"temp_max"];
            dispatch_sync(dispatch_get_main_queue(), ^{
               
         
                self.temperatureLabel.text = self.currentWeather.temperature;
                self.cityLabel.text = [self.currentWeather.locationName copy];
                self.conditionsLabel.text = [self.currentWeather.condition copy];
                self.hiloLabel.text = [NSString stringWithFormat:@"%@ / %@",self.currentWeather.tempLow,self.currentWeather.tempHigh];
                self.iconView.image = [UIImage imageNamed:[WeatherItem imageMap][self.currentWeather.icon]];
                
                NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
                [_formatter setLocale:[NSLocale currentLocale]];
                [_formatter setDateFormat:@"EEEE d.M"];
                NSString *dateFormatted =[_formatter stringFromDate:self.currentWeather.date];
                
                self.dateLabel.text = dateFormatted;
            });
            
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
    }];
    
    [self.client fetchHourlyForecastForLocation:self.location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
        
        for (NSDictionary *hour in data[@"list"]) {
            WeatherItem *item = [[WeatherItem alloc]initWithLocation:hour[@"name"] temperature:hour[@"main"][@"temp"] icon:hour[@"weather"][0][@"icon"] condition:hour[@"weather"][0][@"main"] date:hour[@"dt"]] ;
            
            [self.hourlyWeather addObject:item];
        }
         //   WeatherItem *weather =self.hourlyWeather[0];
            //NSLog(@"counts and wethear:%d %@",self.hourlyWeather.count,weather.temperature);
            [self reloadTableView];
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
    }];
    
    [self.client fetchDailyForecastForLocation:self.location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
            
            for (NSDictionary *day in data[@"list"]) {
                
                WeatherItem *item = [[WeatherItem alloc]initWithLocation:day[@"name"] temperature:day[@"temp"][@"day"] icon:day[@"weather"][0][@"icon"] condition:day[@"weather"][0][@"main"] date:day[@"dt"]] ;
                
                int temp_max = lroundf([day[@"temp"][@"min"] floatValue]);
                int temp_min = lroundf([day[@"temp"][@"max"] floatValue]);
                item.tempLow = [NSString stringWithFormat:@"%d°",temp_min];
                item.tempHigh= [NSString stringWithFormat:@"%d°",temp_max];
                [self.dailyWeather addObject:item];
            }
            [self reloadTableView];
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
        
    }];
    
}
-(void) reloadTableView {
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self.tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (! cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    
   // cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Hourly Forecast"];
        }
        else {
            WeatherItem *weather =self.hourlyWeather[indexPath.row ]; //show from the index 1 coz index 0 shows "current" time
            
                NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
                [_formatter setLocale:[NSLocale currentLocale]];
                [_formatter setDateFormat:@"h a"];
                NSString *dateFormatted =[_formatter stringFromDate:weather.date];
           
            cell.textLabel.text = dateFormatted;
            cell.detailTextLabel.text = weather.temperature;
            cell.imageView.image = [UIImage imageNamed:[WeatherItem imageMap][weather.icon]];
        }
    }
    else if (indexPath.section == 1) {
        
        
        if (indexPath.row == 0) {
            [self configureHeaderCell:cell title:@"Daily Forecast"];
        }
        else {
            WeatherItem *weather =self.dailyWeather[indexPath.row ];
            NSDateFormatter *_formatter=[[NSDateFormatter alloc]init];
            [_formatter setLocale:[NSLocale currentLocale]];
            [_formatter setDateFormat:@"EEEE"];
            NSString *dateFormatted =[_formatter stringFromDate:weather.date];
            
            cell.textLabel.text = dateFormatted;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/%@",weather.tempLow,weather.tempHigh];
            cell.imageView.image = [UIImage imageNamed:[WeatherItem imageMap][weather.icon]];
        }
    }
    
    return cell;
}

- (void)configureHeaderCell:(UITableViewCell *)cell title:(NSString *)title {

    ;
    cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:20];
    cell.textLabel.text = title;
    cell.detailTextLabel.text = @"";
    cell.imageView.image = nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 75.0f;
    }
    return 60.0f;
}



#pragma mark - table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
        
        if (self.hourlyWeather.count>8) {
            return 9;
        }
        return self.hourlyWeather.count+1;
    }
    else if (section == 1){
    if (self.dailyWeather.count>8) {
        return 9;
    }
    return self.dailyWeather.count+1;
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:@"Test"
                                                        message:@"Message here"
                                                       delegate:nil
                                              cancelButtonTitle:@"Done"
                                              otherButtonTitles:nil];
    
    // Add your subviews here to customise
    UIView *contentView = alertView.contentView;
    [alertView show];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.bluredView.alpha=percent;
}

@end
