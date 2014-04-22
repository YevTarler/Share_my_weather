//
//  NetworkClient.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/21/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "NetworkClient.h"

@implementation NetworkClient

-(id)init {
    self = [super init];
    if (self) {
        NSURLSessionConfiguration* config = [NSURLSessionConfiguration defaultSessionConfiguration];
        self.session = [NSURLSession sessionWithConfiguration:config];
    }
    return self;
}

+ (NetworkClient *)sharedInstance // shared "store"
{
    static NetworkClient *_sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //init woth the designated initializer
        _sharedInstance = [[self alloc] init]; //use designated init here !
    });
    
    return _sharedInstance;
}
//general methods:

//use it in a complition handler. with data from session block


//methods for the app
- (void)fetchCurrentConditionsForLocation:(CLLocationCoordinate2D)coordinate completion:(void (^)(NSDictionary *, NSError *))completion  {
    // 1
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%f&lon=%f&units=imperial",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
        // 2
    
  //[self fetchJSONFromURL:url];
    
    NSDictionary *jsonDict = nil;
    NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (! error) {
            NSError *jsonError;
            NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
            
        //    NSLog(@"json is: %@",[jsonDict description]);
            completion(jsonDict,nil);
            
            if (!jsonError) {
                
                completion(jsonDict,nil);
            }
            else{
                completion(nil,jsonError);
            }
        }
        else {
            // 2
            completion(nil,error);
            NSLog(@"connection error");
            
        }
        
        NSLog(@"request completed - current");
        
    }];
    
    // 3
    [dataTask resume];

    
    
}
- (void) fetchHourlyForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(void(^)(NSDictionary *data, NSError *error))completion
 {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&units=imperial&cnt=12",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    
    
     NSDictionary *jsonDict = nil;
     NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (! error) {
             NSError *jsonError;
             NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
             
         //    NSLog(@"json is: %@",[jsonDict description]);
             completion(jsonDict,nil);
             
             if (!jsonError) {
                 
                 completion(jsonDict,nil);
             }
             else{
                 completion(nil,jsonError);
             }
         }
         else {
             // 2
             completion(nil,error);
             NSLog(@"connection error");
             
         }
         
         NSLog(@"request completed - Hourly");
         
     }];
     
     // 3
     [dataTask resume];
}

- (void)fetchDailyForecastForLocation:(CLLocationCoordinate2D)coordinate completion:(void(^)(NSDictionary *data, NSError *error))completion
 {
    NSString *urlString = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/forecast/daily?lat=%f&lon=%f&units=imperial&cnt=7",coordinate.latitude, coordinate.longitude];
    NSURL *url = [NSURL URLWithString:urlString];
    
    // Use the generic fetch method and map results to convert into an array of Mantle objects
     NSDictionary *jsonDict = nil;
     NSURLSessionDataTask *dataTask = [self.session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
         if (! error) {
             NSError *jsonError;
             NSDictionary* jsonDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&jsonError];
             
            // NSLog(@"json is: %@",[jsonDict description]);
             completion(jsonDict,nil);
             
             if (!jsonError) {
                 
                 completion(jsonDict,nil);
             }
             else{
                 completion(nil,jsonError);
             }
         }
         else {
             // 2
             completion(nil,error);
             NSLog(@"connection error");
             
         }
         
         NSLog(@"request completed - Daily");
         
     }];
     
     // 3
     [dataTask resume];
}




@end
