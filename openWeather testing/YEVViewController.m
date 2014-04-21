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


@interface YEVViewController ()
{
    NSString * city;
    NSString* temp;
 
}
@property (nonatomic,strong) NetworkClient *client;


@property (nonatomic,strong) NSMutableArray* hourlyWeather;
@property (nonatomic,strong) NSMutableArray* dailyWeather;
@property (nonatomic,strong) WeatherItem* currentWeather;
@end

@implementation YEVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    self.hourlyWeather = [[NSMutableArray alloc]init];
    self.dailyWeather = [[NSMutableArray alloc]init];
    
    [self reloadData];
    

    UIImage *background = [UIImage imageNamed:@"bg"];
    self.backgroundImageView.image = background;
    
    self.blurredImageView = [[UIImageView alloc] init];
    self.blurredImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.blurredImageView.alpha = 0;
   // [self.blurredImageView setImageToBlur:background blurRadius:10 completionBlock:nil];
  //  [self.view addSubview:self.blurredImageView];
    
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView setOpaque: NO];
    //    CGRect headerFrame = [UIScreen mainScreen].bounds;
    //
    //    header *head = [[header alloc]initWithFrame:headerFrame];
    //
    //    head.backgroundColor = [UIColor clearColor];
    //    self.tableView.tableHeaderView = head;
    
}


                    
- (void)reloadData
{
    //WeatherClient *client = [WeatherClient sharedClient];
    self.client = [NetworkClient sharedInstance];
    CLLocation *location = [[LocationManager sharedManager] currentLocation];
    
    [self.client fetchCurrentConditionsForLocation:location.coordinate completion:^(NSDictionary *data, NSError *error) {
       // NSLog(@"callback: %@", [data description]);
        if (!error) {
           // NSLog(@"name: %@ ",data[@"name"]);
          //  NSLog(@"temp: %@ ",data[@"dt"]);
            // WeatherItem *item = [[WeatherItem alloc]initWithLocation:data[@"name"] temperature:data[@"name"][@"temp"] icon:nil condition:nil date:nil] ;
            
            self.currentWeather = [[WeatherItem alloc]initWithLocation:data[@"name"] temperature:data[@"main"][@"temp"] icon:data[@"weather"][0][@"icon"] condition:data[@"weather"][0][@"main"] date:data[@"dt"]] ;
           // NSLog(@"weather that i need: %@ ",item);
            //NSLog(@"weather celsius %@ ",[item fahrenheitToCelsius]);
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
        
    }];
    
    [self.client fetchHourlyForecastForLocation:location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
        
        for (NSDictionary *hour in data[@"list"]) {
            WeatherItem *item = [[WeatherItem alloc]initWithLocation:hour[@"name"] temperature:hour[@"main"][@"temp"] icon:hour[@"weather"][0][@"icon"] condition:hour[@"weather"][0][@"main"] date:hour[@"dt"]] ;
            
            [self.hourlyWeather addObject:item];
        }
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
    }];
    
    [self.client fetchDailyForecastForLocation:location.coordinate completion:^(NSDictionary *data, NSError *error) {
        if (!error) {
            
            
            for (NSDictionary *day in data[@"list"]) {
                WeatherItem *item = [[WeatherItem alloc]initWithLocation:day[@"name"] temperature:day[@"temp"][@"day"] icon:day[@"weather"][0][@"icon"] condition:day[@"weather"][0][@"main"] date:day[@"dt"]] ;
                
                [self.dailyWeather addObject:item];
            }
        }
        else {
            NSLog(@"error: %@",[error description]);
        }
        
    }];
    
}



@end
