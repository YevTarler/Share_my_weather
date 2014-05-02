//
//  SearchViewController.m
//  Geolocations
//
//  Created by Héctor Ramos on 8/16/12.
//

#import <Parse/Parse.h>

#import "SearchViewController.h"
#import "CircleOverlay.h"
#import "GeoPointAnnotation.h"
#import "GeoQueryAnnotation.h"
#import "LocationManager.h"
#import "WeatherCollectionViewController.h"
#import "WeatherPhotoDetailViewController.h"
#import "TGRImageZoomAnimationController.h"

enum PinAnnotationTypeTag {
    PinAnnotationTypeTagGeoPoint = 0,
    PinAnnotationTypeTagGeoQuery = 1
};

@interface SearchViewController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, assign) CLLocationDistance radius;
@property (nonatomic, strong) CircleOverlay *targetOverlay;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *radiusButton;
@property (nonatomic) BOOL allUploadsAreShown;
@property (nonatomic) CGRect originalFrame;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *metersLabelButton;
@property (nonatomic,strong) UIImageView* clickedImageView;

@end

@implementation SearchViewController



/*
 בנוסף להתאים את העיגול להכל.
 להגדיר רדיוס התחלתי
 להגביהה את הגובה
 
 
 */

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer {
    UITabBar *tb = self.tabBarController.tabBar;
    
    //UINavigationBar *nb = self.navigationController.navigationBar;
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [UIView animateWithDuration:0.4 animations:^{
            tb.alpha = 0;
            self.navBar.alpha =0;
     //       nb.alpha =0;
            
        }];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [UIView animateWithDuration:0.2 animations:^{
            tb.alpha = 1;
            self.navBar.alpha =1;
     //       nb.alpha =1;
        }];
    }
}
#pragma mark - UIViewController

-(void)viewWillAppear:(BOOL)animated {
    [self updateLocations];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //
    self.allUploadsAreShown = NO;
    self.radiusButton.title = @"Show all         ";
    self.slider.hidden = NO;
    self.metersLabelButton.title = @"Meters";
    self.metersLabelButton.tintColor = [UIColor blackColor];
    //

    self.location = [[LocationManager sharedManager] currentLocation];
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.mapView.region = MKCoordinateRegionMake(self.location.coordinate, MKCoordinateSpanMake(0.08f, 0.08f));
    [self configureOverlay];
    [self sliderValueChanged:self.slider];
}


- (IBAction)toggleRadiusButton:(id)sender {
    if (self.allUploadsAreShown) {
        self.allUploadsAreShown = NO;
        self.radiusButton.title = @"Show all         "; //lame i know
        self.slider.hidden = NO;
        self.metersLabelButton.title = @"Meters";
        self.metersLabelButton.tintColor = [UIColor blackColor];
        
    }
    else{
        self.allUploadsAreShown = YES;
        
        self.radiusButton.title = @"Show by distance";
        self.slider.hidden = YES;
        self.metersLabelButton.title = @"";
    }
    [self configureOverlay];
    
}
#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    static NSString *GeoPointAnnotationIdentifier = @"RedPinAnnotation";
    static NSString *GeoQueryAnnotationIdentifier = @"PurplePinAnnotation";
    
    if ([annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoQueryAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoQueryAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoQuery;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorPurple;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    //        annotationView.animatesDrop = NO;
   //         annotationView.draggable = YES;
            

            
        }
        
        return annotationView;
    } else if ([annotation isKindOfClass:[GeoPointAnnotation class]]) {
        MKPinAnnotationView *annotationView =
        (MKPinAnnotationView *)[mapView
                                dequeueReusableAnnotationViewWithIdentifier:GeoPointAnnotationIdentifier];
        
        if (!annotationView) {
            annotationView = [[MKPinAnnotationView alloc]
                              initWithAnnotation:annotation
                              reuseIdentifier:GeoPointAnnotationIdentifier];
            annotationView.tag = PinAnnotationTypeTagGeoPoint;
            annotationView.canShowCallout = YES;
            annotationView.pinColor = MKPinAnnotationColorRed;
            annotationView.animatesDrop = YES;
            
            
            //__block
            
            GeoPointAnnotation *anno =(GeoPointAnnotation*) annotation;
            PFFile *thumbFile = (PFFile *)[anno.object objectForKey:@"mapThumbnailFile"];
            
            
            [thumbFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
                UIImageView *leftAccessoryView = [[UIImageView alloc]init];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        leftAccessoryView.frame = CGRectMake(0, 0, 35, 35);
                        leftAccessoryView.image = [UIImage imageWithData:data];
                        leftAccessoryView.contentMode = UIViewContentModeScaleAspectFill;
                        annotationView.leftCalloutAccessoryView = leftAccessoryView;
        
    }];
                
            } progressBlock:^(int percentDone) {

            }];
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            
//            GeoPointAnnotation *anno =(GeoPointAnnotation*) annotation;
//            leftAccessoryView.image= anno.thumbnail;
//            leftAccessoryView.frame = CGRectMake(0, 0, 20, 20);
//            leftAccessoryView.contentMode = UIViewContentModeScaleAspectFill;
//            annotationView.leftCalloutAccessoryView = leftAccessoryView;
//            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//            NSLog(@"%@",annotation.title);
        }
        
        return annotationView;
    } 
    
    return nil;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay {
    static NSString *CircleOverlayIdentifier = @"Circle";
    
    if ([overlay isKindOfClass:[CircleOverlay class]]) {
        CircleOverlay *circleOverlay = (CircleOverlay *)overlay;

        MKCircleView *annotationView =
        (MKCircleView *)[mapView dequeueReusableAnnotationViewWithIdentifier:CircleOverlayIdentifier];
        
        if (!annotationView) {
            MKCircle *circle = [MKCircle
                                circleWithCenterCoordinate:circleOverlay.coordinate
                                radius:circleOverlay.radius];
            annotationView = [[MKCircleView alloc] initWithCircle:circle];
        }

        if (overlay == self.targetOverlay) {
            annotationView.fillColor = [UIColor colorWithRed:1.0f green:0.0f blue:0.0f alpha:0.3f];
            annotationView.strokeColor = [UIColor redColor];
            annotationView.lineWidth = 1.0f;
        } else {
            annotationView.fillColor = [UIColor colorWithWhite:0.3f alpha:0.3f];
            annotationView.strokeColor = [UIColor purpleColor];
            annotationView.lineWidth = 2.0f;
        }
        
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState {
    if (![view isKindOfClass:[MKPinAnnotationView class]] || view.tag != PinAnnotationTypeTagGeoQuery) {
        return;
    }
    
    if (MKAnnotationViewDragStateStarting == newState) {
        [self.mapView removeOverlays:self.mapView.overlays];
    } else if (MKAnnotationViewDragStateNone == newState && MKAnnotationViewDragStateEnding == oldState) {
        MKPinAnnotationView *pinAnnotationView = (MKPinAnnotationView *)view;
        GeoQueryAnnotation *geoQueryAnnotation = (GeoQueryAnnotation *)pinAnnotationView.annotation;
        self.location = [[CLLocation alloc] initWithLatitude:geoQueryAnnotation.coordinate.latitude longitude:geoQueryAnnotation.coordinate.longitude];
        [self configureOverlay];
    }
}

- (IBAction)allData:(id)sender {
}
- (IBAction)save:(id)sender {
    
}

#pragma mark - SearchViewController

- (void)setInitialLocation:(CLLocation *)aLocation {
    self.location = aLocation;
    self.radius = 1000;
}


#pragma mark - ()


//Whenever the overlay is added or moved, we need to update the red location pins around it.
//we propebly need to change the height here too
- (IBAction)sliderValueChanged:(UISlider *)aSlider {
    self.radius = aSlider.value;
    
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }

    self.targetOverlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.mapView addOverlay:self.targetOverlay];
}

//refresh
- (IBAction)sliderDidTouchUp:(UISlider *)aSlider {
    if (self.targetOverlay) {
        [self.mapView removeOverlay:self.targetOverlay];
    }
    
    [self configureOverlay];
}

- (void)configureOverlay {
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeOverlays:self.mapView.overlays];
    GeoQueryAnnotation *annotation = [[GeoQueryAnnotation alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
    [self.mapView addAnnotation:annotation];
    
    if (self.allUploadsAreShown) {
        
    }
    else{
    if (self.location) {

        
        CircleOverlay *overlay = [[CircleOverlay alloc] initWithCoordinate:self.location.coordinate radius:self.radius];
        [self.mapView addOverlay:overlay];
        

        
        
    }
        
    }
    [self updateLocations];
}

-(void)viewWillDisappear:(BOOL)animated {
    WeatherCollectionViewController *wcvc = self.tabBarController.viewControllers[0];
    if(self.allUploadsAreShown){
        wcvc.showAll = YES;
    }
    else
        wcvc.showAll = NO;
    wcvc.radius = self.radius;
    wcvc.allWeatherUploads = self.WeatherUploads;
    
    
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// Where the magic happens:

- (void)updateLocations {
    CGFloat kilometers = self.radius/1000.0f;

    PFQuery *query = [PFQuery queryWithClassName:@"WeatherPhoto"];
    [query setLimit:1000];
    [query orderByDescending:@"createdAt"];
    if (!self.allUploadsAreShown) {
        [query whereKey:@"location"
           nearGeoPoint:[PFGeoPoint geoPointWithLatitude:self.location.coordinate.latitude
                                               longitude:self.location.coordinate.longitude]withinKilometers:kilometers];
    }

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            self.WeatherUploads = [NSMutableArray arrayWithArray:objects];
            for (PFObject *object in objects) {
                GeoPointAnnotation *geoPointAnnotation = [[GeoPointAnnotation alloc]
                                                          initWithObject:object];
                [self.mapView addAnnotation:geoPointAnnotation];
            }
            //update the other vc:

            //wvc.radiusLabel.text = [NSString stringWithFormat:@"%f",self.radius];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view
calloutAccessoryControlTapped:(UIControl *)control
{

    if ([view.annotation isKindOfClass:[GeoQueryAnnotation class]]) {
        NSLog(@"this is me!");
        WeatherCollectionViewController *wcvc = self.tabBarController.viewControllers[0];
        [self.tabBarController setSelectedIndex:0];
       [wcvc takePhoto:nil];

        
    }
    else{
    GeoPointAnnotation *anno = (GeoPointAnnotation*) view.annotation;
    
    UIImageView *imageview = (UIImageView*) view.leftCalloutAccessoryView;
    self.clickedImageView = imageview;
    WeatherPhotoDetailViewController *weatherDetail = [[WeatherPhotoDetailViewController alloc] initWithImage:imageview.image];
    
    weatherDetail.weatherParseObject = (PFObject *)anno.object;
    weatherDetail.transitioningDelegate = self;
    [self presentViewController:weatherDetail animated:YES completion:nil];
    }
}

//transition to show the images
#pragma mark - UIViewControllerTransitioningDelegate methods

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    if ([presented isKindOfClass:WeatherPhotoDetailViewController.class]) {
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.clickedImageView];
    }
    return nil;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    if ([dismissed isKindOfClass:WeatherPhotoDetailViewController.class]) {
        
        return [[TGRImageZoomAnimationController alloc] initWithReferenceImageView:self.clickedImageView];
    }
    return nil;
}

@end
