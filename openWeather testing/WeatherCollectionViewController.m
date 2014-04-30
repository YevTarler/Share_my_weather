//
//  MJViewController.m
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "WeatherCollectionViewController.h"
#import "MJCollectionViewCell.h"
#import "LMAlertView.h"


#import "LMModalSegue.h"

#import "preUploadViewController.h"
#import "YEVPopShareViewController.h"
#import <BlurryModalSegue.h>
#import "NewMapViewController.h"

#import "WeatherPhotoUpload.h"
#import "WeatherPhotoUploadStore.h"
#import "YEVClearToolbar.h"
#import "WeatherUploadDetailViewController.h"


#import "WeatherPhotoDetailViewController.h"
#import "TGRImageZoomAnimationController.h"

@interface WeatherCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate,UIViewControllerTransitioningDelegate>
{
    UIRefreshControl *_refreshControl;
    BOOL dataDownloaded ;
    BOOL imageSelected ;
}
@property (weak, nonatomic) IBOutlet UICollectionView *parallaxCollectionView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cameraBarButton;
@property (weak, nonatomic) IBOutlet YEVClearToolbar *toolbar;

@property (nonatomic,strong) NSData *imageData;
@property (nonatomic,strong) UIImage *imageNeto;
@property (nonatomic,strong) preUploadViewController *preShareVC;

@property (nonatomic,strong) UIImageView *clickedImageView;
@end

@implementation WeatherCollectionViewController



- (void)viewDidLoad
{

    imageSelected = NO;
    dataDownloaded = NO;
    allWeatherUploads = [[NSMutableArray alloc] init];
    [self getPhotosFromNetwork];
    //pull to refresh:
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor lightGrayColor];
    [_refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.parallaxCollectionView addSubview:_refreshControl];
    self.parallaxCollectionView.alwaysBounceVertical = YES;
    _imageNeto = [[UIImage alloc]init];
    
    
	// Do any additional setup after loading the view, typically from a nib.
    
    
    
    [self.parallaxCollectionView reloadData];
}
-(void) refershControlAction {
    
    [[WeatherPhotoUploadStore sharedWeatherUploadsStore] removeAllObjects];

    [self getPhotosFromNetwork];
}


#pragma mark - PARSING NETWORK DATA METHODS

- (void)uploadWeatherObject:(WeatherPhotoUpload *)WeatherPhotoUpload{
    
    NSData *imageData = UIImageJPEGRepresentation(WeatherPhotoUpload.uploaderImage, 0.5f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data: imageData];
    

    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Uploading";
    [HUD show:YES];
    
    // Save PFFile
    NSData *thumbnailData = UIImageJPEGRepresentation(WeatherPhotoUpload.thumbnail, 0.5f);
    PFFile *thumbnailFile = [PFFile fileWithName:@"thumbnailImage.jpg" data: thumbnailData];
    [thumbnailFile saveInBackground];
    
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
        }
        else {

            
            //    NSData *imageData = UIImagePNGRepresentation(thumbnail);
            //    PFFile *imageFile = [PFFile fileWithName:@"thumbnailImage.png" data:imageData];
            //    [imageFile save];
            
            //Hide determinate HUD
            [HUD hide:YES];
            // Show checkmark
            HUD = [[MBProgressHUD alloc] initWithView:self.view];
            [self.view addSubview:HUD];
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]]; //  The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.delegate = self;
            
            // Setting PARSE object:
            PFObject *weatherUpload = [PFObject objectWithClassName:@"WeatherPhoto"];
            
            [weatherUpload setObject:imageFile forKey:@"imageFile"];
            [weatherUpload setObject:thumbnailFile forKey:@"thumbnailFile"];
            
            weatherUpload[@"name"] = WeatherPhotoUpload.uploaderName;
            weatherUpload[@"describtion"] = WeatherPhotoUpload.uploaderDescription;
            weatherUpload[@"city"] = WeatherPhotoUpload.uploaderLocationCity;
            
            //TODO: SET GEOLOCATION
            PFGeoPoint *geoPoint = [PFGeoPoint geoPointWithLatitude:WeatherPhotoUpload.locationWherePictureTaken.coordinate.latitude
                                                          longitude:WeatherPhotoUpload.locationWherePictureTaken.coordinate.longitude];
            [weatherUpload setObject:geoPoint forKey:@"location"];
            
            [weatherUpload saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                else{
                    // We might want to update the local dataModel ?
                    
                    [self addWeatherPhotoObject:weatherUpload];
                   // [self refresh:nil];
                    
                }
            }];
        }
    }
     progressBlock:^(int percentDone) {
        HUD.progress = (float)percentDone/100;
    }];
    [self.parallaxCollectionView reloadData];
}

-(void) addWeatherPhotoObject: (PFObject*)weatherPhoto {
    [allWeatherUploads insertObject:weatherPhoto atIndex:0];
    if (allWeatherUploads.count >14) { //show only X
        PFObject* lastObj = [allWeatherUploads lastObject];
        [lastObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"succesfully deleted");
                [allWeatherUploads removeLastObject];
                [[WeatherPhotoUploadStore sharedWeatherUploadsStore] removeLastWeatherObject];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.parallaxCollectionView reloadData];
        
    }];
            }
            else{
                NSLog(@"error has eccured");
            }
        }];
    }
    else {
        [self.parallaxCollectionView reloadData];
            NSLog(@"count of allWeatherUploads: %lu storedata: %lu", (unsigned long)allWeatherUploads.count,(unsigned long)[[WeatherPhotoUploadStore sharedWeatherUploadsStore] getAllWeatherUploads].count);
    }
}


-(void) getPhotosFromNetwork {
    refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:refreshHUD];
    // Register for HUD callbacks so we can remove it from the window at the right time
    refreshHUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [refreshHUD show:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"WeatherPhoto"];
    [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if(error) {
            [refreshHUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else{
            if (_refreshControl) {
                [_refreshControl endRefreshing];
            }
            
            if (refreshHUD) {
                [refreshHUD hide:YES];
                refreshHUD = [[MBProgressHUD alloc] initWithView:self.view];
                [self.view addSubview:refreshHUD];
                refreshHUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
                refreshHUD.mode = MBProgressHUDModeCustomView;
                refreshHUD.delegate = self;
            }
            NSMutableArray *newObjectIDArray = [NSMutableArray array];
            if (objects.count > 0) {
                int i=0;
                for (PFObject *eachObject in objects) {
                    [newObjectIDArray addObject:[eachObject objectId]];
                    NSLog(@"date of obj in index %d is: %@",i,eachObject[@"createdAt"]);
                }
            }
            /*
             we can keep an array og PFObject's "old"( and "new" ) check every "titleForState" of what we have and compare it with the new one - we do it by removing from the new one the old ones.
             Its a good practice to also check if the "amin" removed some photos from the network - do it by comparing 2 arrays of "old" - removing from the old all "new" we first got(2 arrays of new) so we know what is in the view but not in the network
             */
            
            // Add new objects
            if (objects.count > 0) {
                allWeatherUploads = [NSMutableArray arrayWithArray:objects];
            }
            // TODO: check what ascending means?

            
            dataDownloaded = YES;
            [self.parallaxCollectionView reloadData];


        }
    }];

    
}

#pragma mark - IBActions and segue

- (IBAction)llongTap:(id)sender {
    NSLog(@"long tap");
    
}


- (IBAction)swipeBack:(id)sender {

    [self dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)takePhoto:(id)sender {
    
    // Check for camera
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES) {
        // Create image picker controller
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        // Set source to the camera
        imagePicker.sourceType =  UIImagePickerControllerSourceTypeCamera;
        
        // Delegate is self
        imagePicker.delegate = self;
        
        // Show image picker
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
    else{
        // Device has no camera
    }
    
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{

    
    [picker dismissViewControllerAnimated:NO completion:nil];
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    
    
    
    // UIImage *original = <original UIImage>;
    CGSize thumbnailSize = CGSizeMake(image.size.width*0.07, image.size.height*0.07);
    UIGraphicsBeginImageContextWithOptions(thumbnailSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height)];
    UIImage *thumbnail = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CGSize newSize = CGSizeMake(image.size.width*0.20, image.size.height*0.20);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *compressedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

	
     UINavigationController* navCont = [self.storyboard instantiateViewControllerWithIdentifier:@"navToPost"];
    self.preShareVC =(preUploadViewController*) [navCont topViewController];
    self.preShareVC.imageFromController = thumbnail;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    self.preShareVC.callback = ^(NSString *name, NSString *description, NSString *city, CLLocation *location) {
        
        // I DONT THINK I NEED ALL THOSE PARAMS but its 3 am
        WeatherPhotoUpload *newWeatherUpload = [[WeatherPhotoUpload alloc] initWithName:name Image:compressedImage ImageDescription:description];
        newWeatherUpload.thumbnail = thumbnail;
        newWeatherUpload.locationWherePictureTaken = location;
        
        //not realy needed
        [[WeatherPhotoUploadStore sharedWeatherUploadsStore] pushWeatherUploadToBeginning:newWeatherUpload];
        
        
        newWeatherUpload.uploaderLocationCity = @"none";
        if (city)
            newWeatherUpload.uploaderLocationCity = city;
        //TODO: YOU ARE HERE: check it
        [weakSelf uploadWeatherObject:newWeatherUpload];
    };
    LMAlertView *alertView = [[LMAlertView alloc] initWithViewController:navCont];

    
    [alertView show];
    [picker dismissViewControllerAnimated:NO completion:nil];

}
-(void) compressImageBySize:(UIImage*) image{
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 250*1024;
    
    NSData *imageData = UIImageJPEGRepresentation(image, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(image, compression);
    }
    
}
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UICollectionViewDatasource Methods

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    MJCollectionViewCell *cell =nil;
    if(indexPath.row ==0)
        //smth
        cell = (MJCollectionViewCell*) [self.parallaxCollectionView cellForItemAtIndexPath: indexPath];
    else
        cell =  (MJCollectionViewCell*)[self.parallaxCollectionView viewWithTag:indexPath.row];
    
    NSLog(@"the index is %d",indexPath.row);
    self.clickedImageView = cell.MJImageView;
    WeatherPhotoDetailViewController *weatherDetail = [[WeatherPhotoDetailViewController alloc] initWithImage:self.clickedImageView.image];
    weatherDetail.weatherParseObject = (PFObject *)[allWeatherUploads objectAtIndex:indexPath.row];
    weatherDetail.transitioningDelegate = self;
    [self presentViewController:weatherDetail animated:YES completion:nil];
    

 //   WeatherPhotoDetailViewController *viewController =
//    WeatherPhotoDetailViewController *viewController = [[WeatherPhotoDetailViewController alloc] initWithImage:chosenWeatherUpload.uploaderImage name:chosenWeatherUpload.uploaderName describtion:chosenWeatherUpload.uploaderDescription city:@"check"]; //chosenWeatherUpload.uploaderLocationCity
//    viewController.transitioningDelegate = self;
//    [self presentViewController:viewController animated:YES completion:nil];
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (dataDownloaded) {
        return allWeatherUploads.count;
    }
    return 0;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MJCell" forIndexPath:indexPath];
    
    
    //NSInteger count = allWeatherUploads.count-1;
    PFObject *parseObj = (PFObject *)[allWeatherUploads objectAtIndex:indexPath.row];
    cell.tag = indexPath.row;
    
    PFFile *theImage = [parseObj objectForKey:@"thumbnailFile"];
    __block NSData *imageData;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        imageData = data;
        UIImage *selectedPhoto = [UIImage imageWithData:imageData];
        
       //  WeatherPhotoUpload *wpu = [[WeatherPhotoUpload alloc] initWithName:parseObj[@"name"] Image:selectedPhoto ImageDescription:parseObj[@"describtion"]];
       // [[WeatherPhotoUploadStore sharedWeatherUploadsStore] addWeatherUpload:wpu ];
        
        cell.image = selectedPhoto;
        
        CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        cell.imageOffset = CGPointMake(0.0f, yOffset);
    } progressBlock:^(int percentDone) {
        
    }];
    return cell;
    
}

//NOT USED !
-(void) syncParseObjectWithLocalData {
    
    for (PFObject *parseObj in allWeatherUploads) {
        PFFile *theImage = [parseObj objectForKey:@"imageFile"];
        __block NSData *imageData;
        [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            imageData = data;
            UIImage *selectedPhoto = [UIImage imageWithData:imageData];
            WeatherPhotoUpload *wpu = [[WeatherPhotoUpload alloc] initWithName:parseObj[@"name"] Image:selectedPhoto ImageDescription:parseObj[@"describtion"]];
            NSLog(@"PARSE: %@, %@", parseObj[@"name"],parseObj[@"describtion"] );
            [[WeatherPhotoUploadStore sharedWeatherUploadsStore] addWeatherUpload:wpu ];
        } progressBlock:^(int percentDone) {
            
        }];

    }
   
    
}



#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
        CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}


#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
	HUD = nil;
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
