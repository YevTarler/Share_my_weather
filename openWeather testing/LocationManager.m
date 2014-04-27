#import "LocationManager.h"

NSString * const kLocationDidChangeNotificationKey = @"locationManagerlocationDidChange";
NSString * const kAddressOfCurrentLocationNotificationKey = @"addressOfCurrentLocation";
@interface LocationManager () <CLLocationManagerDelegate>
{
    CLGeocoder *_geocoder;
}
@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, readwrite) BOOL           isMonitoringLocation;


@end

@implementation LocationManager

+ (instancetype)sharedManager
{
    static LocationManager *_sharedLocationManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedLocationManager = [[LocationManager alloc] init];
    });
    
    return _sharedLocationManager;
}



#pragma mark - Public API

- (void)startMonitoringLocationChanges
{
    if ([CLLocationManager locationServicesEnabled])
    {
        if (!self.isMonitoringLocation)
        {
            self.isMonitoringLocation = YES;
            self.locationManager.delegate = self;
            [self.locationManager startMonitoringSignificantLocationChanges];
        }
    }
    else
    {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"This app requires location services to be enabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

- (void)stopMonitoringLocationChanges
{
    if (_locationManager)
    {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        self.locationManager.delegate = nil;
        self.isMonitoringLocation = NO;
        self.locationManager = nil;
    }
}

#pragma mark - Accessors

- (CLLocationManager *)locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    return _locationManager;
}

- (CLLocation *)currentLocation
{
    return self.locationManager.location;
}

#pragma mark - CLLocationManagerDelegate

//- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
//{
//    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
//    if (newLocation) {
//        userInfo[@"newLocation"] = newLocation;
//    }
//    if (oldLocation) {
//        userInfo[@"oldLocation"] = oldLocation;
//    }
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationDidChangeNotificationKey
//                                                        object:self
//                                                      userInfo:userInfo];
//}

-(void) getAddressOfCurrentLocation {
    if (_geocoder == nil)
        _geocoder = [[CLGeocoder alloc] init];
    //Only one geocoding instance per action
    //so stop any previous geocoding actions before starting this one
    if([_geocoder isGeocoding])
        [_geocoder cancelGeocode];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
    [_geocoder reverseGeocodeLocation:[self currentLocation] completionHandler:^(NSArray *placemarks, NSError *error) {
        
        if([placemarks count] > 0)
        {
            CLPlacemark* foundPlacemark = [placemarks objectAtIndex:0];
           // NSLog(@"You are in: %@", foundPlacemark.description);
            NSString *city = [foundPlacemark.locality copy];
            [userInfo setValue:foundPlacemark forKey:@"placemark"];
            // self.geocodingResultsView.text = [NSString stringWithFormat:@"You are in: %@", foundPlacemark.description];
        }
        else if (error.code == kCLErrorGeocodeCanceled)
        {
            //NSLog(@"Geocoding cancelled");
            [userInfo setValue:error forKey:@"error"];
        }
        else if (error.code == kCLErrorGeocodeFoundNoResult)
        {
            //NSLog(@"No geocode result found");
            [userInfo setValue:error forKey:@"error"];
        }
        else if (error.code == kCLErrorGeocodeFoundPartialResult)
        {
            //(@"Partial geocode result");
            [userInfo setValue:error forKey:@"error"];
        }
        else {
            //NSLog(@"Unknown error: %@",error.description);
            [userInfo setValue:error forKey:@"error"];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kAddressOfCurrentLocationNotificationKey object:self userInfo:userInfo];
    }];


}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    // 1
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        
      //  NSLog(@"latitude %+.6f, longitude %+.6f\n",location.coordinate.latitude,location.coordinate.longitude);
        // If the event is recent, do something with it.
  
    }

}

- (void)locationManager:(CLLocationManager*)manager didFailWithError:(NSError*)error
{
    if ([error code]== kCLErrorDenied)
    {
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Denied" message:@"This app requires location services to be allowed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    }
}

@end