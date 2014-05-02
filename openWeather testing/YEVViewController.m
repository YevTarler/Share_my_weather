//
//  YEVViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "YEVViewController.h"

#import "WeatherItem.h"
#import "WeatherCollectionViewController.h"

#import "BouncePresentTransition.h"
#import "FXBlurView.h"

#import <BlurryModalSegue.h>
#import <LMAlertView.h>

@interface YEVViewController ()
{
    NSString * city;
    NSString* temp;
    UIRefreshControl *_refreshControl;
 
}
@property (strong, nonatomic) LMAlertView *ratingAlertView;

@property (nonatomic,strong) NetworkClient *client;


@property (nonatomic,strong) NSMutableArray* hourlyWeather;
@property (nonatomic,strong) NSMutableArray* dailyWeather;
@property (nonatomic,strong) WeatherItem* currentWeather;





@property (nonatomic,strong) WeatherCollectionViewController *mjrvc;
@property (weak, nonatomic) IBOutlet FXBlurView *bluredView;



@end

@implementation YEVViewController 


- (void)viewDidLoad
{
    
    [super viewDidLoad];

    _refreshControl = [[UIRefreshControl alloc] init];
    
    
    
    _refreshControl.tintColor = [UIColor whiteColor];
    [_refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    
  //  self.location = [[LocationManager sharedManager] currentLocation];
    NSLog(@"location is: %f %f", self.location.coordinate.longitude,self.location.coordinate.latitude);
    self.screenHeight = [UIScreen mainScreen].bounds.size.height;
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self selector:@selector(receivedBackgroundNotification:) name:@"locationGranted" object:nil];
    [notificationCenter addObserver:self selector:@selector(receivedBackgroundNotification:) name:@"backgroundImageNotification" object:nil];


    [self.tableView addSubview:_refreshControl];
    self.bluredView.blurRadius = 25;
    self.bluredView.alpha=0;
    //transition:
    self.modalPresentationStyle = UIModalPresentationCustom; //1
    
    
    self.hourlyWeather = [[NSMutableArray alloc]init];
    self.dailyWeather = [[NSMutableArray alloc]init];
    UIImage *background =[self getImage:@"shareMyWeatherBackground"];
    if(!background)
        background= [UIImage imageNamed:@"bg"];
    self.backgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.backgroundImageView.image = background;

  
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *headerV = self.headerView;
    self.tableView.tableHeaderView = headerV;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];

    
    
    //
    
    [self reloadData];
}

-(void) refershControlAction {
    
    [self reloadData];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSLog(@"view will appear");
    self.bluredView.blurRadius = 25;
    self.bluredView.alpha=0;
    //transition:

    
    self.tableView.backgroundColor = [UIColor clearColor];
    UIView *headerV = self.headerView;
    self.tableView.tableHeaderView = headerV;
    self.tableView.separatorColor = [UIColor colorWithWhite:1 alpha:0.2];
    
    
    self.location = [[LocationManager sharedManager] currentLocation];
    //
    
    [self reloadData];
}
-(void) receivedBackgroundNotification: (NSNotification*) notification {
    
    if ([notification.name isEqualToString:@"backgroundImageNotification"]) {
        NSLog(@"background recieved");
        UIImage *newBackground = notification.userInfo[@"backgroundImage"];
        self.backgroundImageView.image = newBackground;
        [self saveImage:newBackground filename:@"shareMyWeatherBackground"];
        [self reloadData];
    }
    else if ([notification.name isEqualToString:@"locationGranted"]){
        [self reloadHeader];
        [self.view setNeedsDisplay];
    }
}

- (IBAction)swipedRight:(id)sender {
    static UITabBarController *barController = nil;
    if (!barController) {
        barController = [self.storyboard instantiateViewControllerWithIdentifier:@"tabbarController"];
    }
    barController.transitioningDelegate = self;
    barController.view.backgroundColor = [UIColor clearColor];
    BlurryModalSegue *bms = [[BlurryModalSegue alloc] initWithIdentifier:@"" source:self destination:barController];
    
    bms.backingImageBlurRadius = @(10);
 //  bms.backingImageSaturationDeltaFactor = @(1.8);
    
    bms.backingImageTintColor = [UIColor colorWithWhite:0.01 alpha:0.5] ;
    
    [bms perform];
    
}

- (void)saveImage:(UIImage*)image filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    [data writeToFile:filename atomically:YES];
}

- (UIImage*)getImage:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    return [UIImage imageWithData:data];
}

#pragma mark - Custom animation delegate methods

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {

    return [[BouncePresentTransition alloc]initWithDirection:YevTransitionStyleGoLeft];
}
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {

return [[BouncePresentTransition alloc]initWithDirection:YevTransitionStyleGoRight];}


- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
-(UIView *)headerView {
    if (!_headerView) {
        [[NSBundle mainBundle] loadNibNamed:@"initialHeader" owner:self options:nil];
    }
    return _headerView;
}
-(void) reloadHeader {
    self.client = [NetworkClient sharedInstance];
    self.location = [[LocationManager sharedManager] currentLocation];
    
    [self.client fetchCurrentConditionsForLocation:self.location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
            self.currentWeather = [[WeatherItem alloc]initWithLocation:data[@"name"] temperature:data[@"main"][@"temp"]  icon:data[@"weather"][0][@"icon"] condition:data[@"weather"][0][@"main"] date:data[@"dt"]] ;
            
            
            
            self.currentWeather.tempLow = data[@"main"][@"temp_min"];
            self.currentWeather.tempHigh = data[@"main"][@"temp_max"];
            NSLog(@"temp min:%@ and temp high: %@",data[@"main"][@"temp_min"],data[@"main"][@"temp_max"]);
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
                [self.tableView reloadData];
                //  [self.headerView setNeedsDisplay];
                if (_refreshControl) {
                    [_refreshControl endRefreshing];
                }
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
- (void)reloadData
{
    
    self.client = [NetworkClient sharedInstance];


    
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
            cell.detailTextLabel.backgroundColor = [UIColor clearColor];
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
    else {
        //NSLog(@"height of screen: %f",self.screenHeight);
        NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
        return (self.screenHeight - 75) / ((CGFloat)cellCount-1);
        //return 60.0f;
    }
    
    
 //   NSInteger cellCount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
 //   return self.screenHeight / (CGFloat)cellCount;

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
    LMAlertView *alertView = [[LMAlertView alloc] initWithTitle:@"Test" message:@"Message here" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
    
    //[alertView addButtonWithTitle:@"3rd"];

	NSLog(@"%@: First other button index: %li", [alertView class], (long)alertView.firstOtherButtonIndex);
	NSLog(@"%@: Cancel button index: %li", [alertView class], (long)alertView.cancelButtonIndex);
	NSLog(@"%@: Number of buttons: %li", [alertView class], (long)alertView.numberOfButtons);
	
	[alertView show];
    
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = scrollView.bounds.size.height;
    CGFloat position = MAX(scrollView.contentOffset.y, 0.0);
    CGFloat percent = MIN(position / height, 1.0);
    self.bluredView.alpha=percent;
}
/*
 מה שצריך לעשות:

 אייקון לאפליקציה

 להוסיף חץ לסווייפ
 לנקות מאפליקציות ופרופרטי לא משומשים
 לנקות מתמונות לא משומשות

 
 */
@end
