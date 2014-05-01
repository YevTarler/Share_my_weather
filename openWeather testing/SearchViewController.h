//
//  SearchViewController.h
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <MapKit/MapKit.h>

@interface SearchViewController : UIViewController <MKMapViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

- (void)setInitialLocation:(CLLocation *)aLocation;

@end
