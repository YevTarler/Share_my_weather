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


@interface WeatherCollectionViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    UIRefreshControl *_refreshControl;
    BOOL dataDownloaded ;
}
@property (weak, nonatomic) IBOutlet UICollectionView *parallaxCollectionView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (nonatomic,strong) NSData *imageData;
@property (nonatomic,strong) UIImage *imageNeto;
@property (nonatomic,strong) preUploadViewController *preShareVC;
@end

@implementation WeatherCollectionViewController



- (void)viewDidLoad
{
    [super viewDidLoad];
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
    self.toolBar.backgroundColor = [UIColor clearColor];
    
    
    
    
    [self.parallaxCollectionView reloadData];
}
-(void) refershControlAction {
    [self getPhotosFromNetwork];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"item selected: %d",indexPath.row);

	[UIView animateWithDuration:0.4 animations:^{
		// pop.view.alpha = 1.0f;
	}];
    
}

#pragma mark - PARSING NETWORK DATA METHODS

- (void)uploadWeatherObject:(WeatherPhotoUpload *)WeatherPhotoUpload{
    
    NSData *imageData = UIImageJPEGRepresentation(WeatherPhotoUpload.uploaderImage, 0.05f);
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data: imageData];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    // Set determinate mode
    HUD.mode = MBProgressHUDModeDeterminate;
    HUD.delegate = self;
    HUD.labelText = @"Uploading";
    [HUD show:YES];
    
    // Save PFFile
    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(error){
            [HUD hide:YES];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            
        }
        else {
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
            weatherUpload[@"name"] = WeatherPhotoUpload.uploaderName;
            weatherUpload[@"describtion"] = WeatherPhotoUpload.uploaderDescription;
            weatherUpload[@"city"] = WeatherPhotoUpload.uploaderLocationCity;
       
            [weatherUpload saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                else{
                    // We might want to update the local dataModel ?
                    
                    //[[WeatherPhotoUploadStore sharedWeatherUploadsStore] addWeatherUpload:WeatherPhotoUpload];
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
   // NSArray *allWeatherUploads = [[WeatherPhotoUploadStore sharedWeatherUploadsStore] getAllWeatherUploads];
    [allWeatherUploads addObject:weatherPhoto];
    if (allWeatherUploads.count >14) { //show only X
       // [[WeatherPhotoUploadStore sharedWeatherUploadsStore] removeWeatherUploadAtIndex:0];
        PFObject* firstObj = allWeatherUploads[0];
        [firstObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"succesfully deleted");
                [allWeatherUploads removeObjectAtIndex:0];
                    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                        [self.parallaxCollectionView reloadData];
        
    }];
                //[self setUpImages:allWeatherUploads];
                
                //TODO: FIX HERE, TRY REMOVING ALL MAYBE
            }
            else{
                NSLog(@"error has eccured");
            }
        }];
    }
    else {
        [self.parallaxCollectionView reloadData];
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
    [query orderByAscending:@"createdAt"];
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
            NSLog(@"Successfully retrieved %d weather objects.", objects.count);
            NSMutableArray *newObjectIDArray = [NSMutableArray array];
            if (objects.count > 0) {
                for (PFObject *eachObject in objects) {
                    [newObjectIDArray addObject:[eachObject objectId]];
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
    NSLog(@"swiped back");
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
    
    
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    //[image drawInRect: CGRectMake(0, 0, 640, 640)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.imageNeto = smallImage;
    // Upload image
  //  self.imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    
	
     UINavigationController* navCont = [self.storyboard instantiateViewControllerWithIdentifier:@"navToPost"];
    self.preShareVC =(preUploadViewController*) [navCont topViewController];
    self.preShareVC.imageFromController = smallImage;
    
    __unsafe_unretained typeof(self) weakSelf = self;
    self.preShareVC.callback = ^(NSString *name, NSString *description, NSString *city) {

        NSLog(@"name: %@ description: %@", name,description);
        
        WeatherPhotoUpload *newWeatherUpload = [[WeatherPhotoUpload alloc] initWithName:name Image:smallImage ImageDescription:description];
        newWeatherUpload.uploaderLocationCity = @"none";
        if (city)
            newWeatherUpload.uploaderLocationCity = city;
        
        [weakSelf uploadWeatherObject:newWeatherUpload];
    };
    LMAlertView *alertView = [[LMAlertView alloc] initWithViewController:navCont];

    
    [alertView show];
    [picker dismissViewControllerAnimated:NO completion:nil];

}

- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (dataDownloaded) {
        return allWeatherUploads.count;
    }
    return 0;

}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MJCell" forIndexPath:indexPath];
    
    NSInteger count = allWeatherUploads.count-1;
    PFObject *theObject = (PFObject *)[allWeatherUploads objectAtIndex:count - indexPath.row];
    PFFile *theImage = [theObject objectForKey:@"imageFile"];
    __block NSData *imageData;
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        imageData = data;
        UIImage *selectedPhoto = [UIImage imageWithData:imageData];
        cell.image = selectedPhoto;
    } progressBlock:nil];

    CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    
    return cell;
    
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

@end
