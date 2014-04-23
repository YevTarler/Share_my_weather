//
//  MJViewController.m
//  ParallaxImages
//
//  Created by Mayur on 4/1/14.
//  Copyright (c) 2014 sky. All rights reserved.
//

#import "MJRootViewController.h"
#import "MJCollectionViewCell.h"

@interface MJRootViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
    UIRefreshControl *_refreshControl;
}
@property (weak, nonatomic) IBOutlet UICollectionView *parallaxCollectionView;

@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;

@end

@implementation MJRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPhotosFromNetwork];
    //pull to refresh:
    _refreshControl = [[UIRefreshControl alloc] init];
    _refreshControl.tintColor = [UIColor lightGrayColor];
    [_refreshControl addTarget:self action:@selector(refershControlAction) forControlEvents:UIControlEventValueChanged];
    [self.parallaxCollectionView addSubview:_refreshControl];
    self.parallaxCollectionView.alwaysBounceVertical = YES;
    
    
    
	// Do any additional setup after loading the view, typically from a nib.
    self.toolBar.backgroundColor = [UIColor clearColor];
    allImages = [[NSMutableArray alloc] init];
    
    
    
    [self.parallaxCollectionView reloadData];
}
-(void) refershControlAction {
    [self getPhotosFromNetwork];
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"item selected: %d",indexPath.row);
}


#pragma mark - UICollectionViewDatasource Methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return allImages.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MJCollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MJCell" forIndexPath:indexPath];
    
    NSInteger count = allImages.count-1;
    PFObject *theObject = (PFObject *)[allImages objectAtIndex:count - indexPath.row];
    PFFile *theImage = [theObject objectForKey:@"imageFile"];
    NSData *imageData;
    imageData = [theImage getData];
    UIImage *selectedPhoto = [UIImage imageWithData:imageData];
    cell.image = selectedPhoto;
    CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - cell.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
    cell.imageOffset = CGPointMake(0.0f, yOffset);
    
    return cell;

}
- (IBAction)swipeBack:(id)sender {
    NSLog(@"swiped back");
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIScrollViewdelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    for(MJCollectionViewCell *view in self.parallaxCollectionView.visibleCells) {
        CGFloat yOffset = ((self.parallaxCollectionView.contentOffset.y - view.frame.origin.y) / IMAGE_HEIGHT) * IMAGE_OFFSET_SPEED;
        view.imageOffset = CGPointMake(0.0f, yOffset);
    }
}



#pragma mark - others
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



- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}
#pragma mark -
#pragma mark UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Access the uncropped image from info dictionary
    UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    
    // Dismiss controller
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    // Resize image
    UIGraphicsBeginImageContext(CGSizeMake(640, 960));
    [image drawInRect: CGRectMake(0, 0, 640, 960)];
    UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Upload image
    NSData *imageData = UIImageJPEGRepresentation(smallImage, 0.05f);
    [self uploadImage:imageData];
    
    
    
}



- (void)uploadImage:(NSData *)imageData{
    
    PFFile *imageFile = [PFFile fileWithName:@"Image.jpg" data:imageData];
    
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
            HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]]; //// Make the customViews 37 by 37 pixels for best results (those are the bounds of the build-in progress indicators).  The sample image is based on the work by http://www.pixelpressicons.com, http://creativecommons.org/licenses/by/2.5/ca/
            // Set custom view mode
            HUD.mode = MBProgressHUDModeCustomView;
            HUD.delegate = self;
            
            // HERE THE INTERESTING PART :
            PFObject *weatherPhoto = [PFObject objectWithClassName:@"WeatherPhoto"];
            [weatherPhoto setObject:imageFile forKey:@"imageFile"];
            //set other properties here like location/tempreture
            
            [weatherPhoto saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                else{
                    // We might want to update the local dataModel ?
                    
                    [self addOWeatherPhotoObject:weatherPhoto];
                   // [self refresh:nil];
                    
                }
            }];
        }
    }
     progressBlock:^(int percentDone) {
        HUD.progress = (float)percentDone/100;
    }];

}

-(void) addOWeatherPhotoObject: (PFObject*)weatherPhoto {
    [allImages addObject:weatherPhoto];
    if (allImages.count >15) { //lets say we only want 5
        PFObject* firstObj = allImages[0];
        [firstObj deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"succesfully deleted");
                [allImages removeObjectAtIndex:0];
                [self setUpImages:allImages];
            }
            else{
                NSLog(@"error has eccured");
            }
        }];
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
            NSLog(@"Successfully retrieved %d photos.", objects.count);
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
                allImages = [NSMutableArray arrayWithArray:objects];
            }
            
            [self setUpImages:allImages]; //change uivew
            

        }
    }];

    
}

- (void)setUpImages:(NSArray *)images{
    NSLog(@"count images in allImages: %d",images.count);
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                       [self.parallaxCollectionView reloadData];
                       
                   });
    
}
#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD hides
    [HUD removeFromSuperview];
	HUD = nil;
}
@end
