// TGRImageZoomTransition.m
//
// Copyright (c) 2013 Guillermo Gonzalez
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "WeatherPhotoDetailViewController.h"
#import "UzysSlideMenu.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface WeatherPhotoDetailViewController ()

@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *singleTapGestureRecognizer;
@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *doubleTapGestureRecognizer;
//@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *swipeUpTapGestureRecognizer;
//@property (weak, nonatomic) IBOutlet UITapGestureRecognizer *swipeDownTapGestureRecognizer;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (nonatomic,strong) ALAssetsLibrary* library;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic,strong) UzysSlideMenu* uzysSMenu;
@end

@implementation WeatherPhotoDetailViewController

- (id)initWithImage:(UIImage *)image {
    if (self = [super init]) {
        _image = image;
    }
    
    return self;
}
- (id)initWithImage:(UIImage *)image name:(NSString*) name description:(NSString*)desc city:(NSString*)city {
    if (self = [super init]) {
        _image = image;
        _name = name;
        _city = city;
        _description = desc;
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageView.image = self.image;
    self.nameLabel.text = self.weatherParseObject[@"name"];
    self.cityLabel.text = self.weatherParseObject[@"city"];
    self.descriptionTextView.text = self.weatherParseObject[@"description"];
    
 [self.activityIndicator setHidden:YES];
    PFFile *theImage = [self.weatherParseObject objectForKey:@"imageFile"];
    __block NSData *imageData;
  //  [self.activityIndicator startAnimating];
    [theImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
        
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                UIImage *selectedPhoto = [UIImage imageWithData:data];
                self.image = selectedPhoto;
                self.imageView.image = self.image;
              //  self.imageView.image = [UIImage imageNamed:@"bg"];
              //  [self.activityIndicator setHidden:YES];
             //   [self.activityIndicator stopAnimating];
                NSLog(@"new image downloaded! ");
        }];
        
        
    }];
    
    [self.singleTapGestureRecognizer requireGestureRecognizerToFail:self.doubleTapGestureRecognizer];


    
    ah__block typeof(self) blockSelf = self;
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"" image:[UIImage imageNamed:@"Menu2Icon"] action:^(UzysSMMenuItem *item) {
       // NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);

    }];
    __weak typeof(self) weakSelf = self;
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Download" image:[UIImage imageNamed:@"downloadMenuIcon"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        _library = [[ALAssetsLibrary alloc] init];
        __weak ALAssetsLibrary *lib = self.library;
        
        [self.library addAssetsGroupAlbumWithName:@"ShareMyWeather" resultBlock:^(ALAssetsGroup *group) {
            
            ///checks if group previously created
            if(group == nil){
                
                //enumerate albums
                [lib enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                   usingBlock:^(ALAssetsGroup *g, BOOL *stop)
                 {
                     //if the album is equal to our album
                     if ([[g valueForProperty:ALAssetsGroupPropertyName] isEqualToString:@"ShareMyWeather"]) {
                         
                         //save image
                         [lib writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(weakSelf.imageView.image) metadata:nil
                                               completionBlock:^(NSURL *assetURL, NSError *error) {
                                                   
                                                   //then get the image asseturl
                                                   [lib assetForURL:assetURL
                                                        resultBlock:^(ALAsset *asset) {
                                                            //put it into our album
                                                            [g addAsset:asset];
                                                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Photo saved in ShareMyWeather album" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
                                                        } failureBlock:^(NSError *error) {
                                                                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
                                                        }];
                                               }];
                         
                     }
                 }failureBlock:^(NSError *error){
                                 UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
                 }];
                
            }else{
                // save image directly to library
                [lib writeImageDataToSavedPhotosAlbum:UIImagePNGRepresentation(weakSelf.imageView.image) metadata:nil
                                      completionBlock:^(NSURL *assetURL, NSError *error) {
                                          
                                          [lib assetForURL:assetURL
                                               resultBlock:^(ALAsset *asset) {
                                                   
                                                   [group addAsset:asset];
                                                   UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Photo saved in a new ShareMyWeather album" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                                                   [alert show];
                                                   
                                               } failureBlock:^(NSError *error) {
                                                               UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
                                               }];
                                      }];
            }
            
        } failureBlock:^(NSError *error) {
                        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:weakSelf cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }];
        

    }];
    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Set as background" image:[UIImage imageNamed:@"setBackgrounMenuIcon"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"backgroundImageNotification" object:self userInfo:@{@"backgroundImage": self.image}];
       // [self dismissViewControllerAnimated:YES completion:nil];
        
        
        
    }];
    
    
    UzysSMMenuItem *item3 = [[UzysSMMenuItem alloc] initWithTitle:@"Share with friends" image:[UIImage imageNamed:@"shareMenuIcon"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        
        
        
        //
        // start activity indicator
        [self.activityIndicator setHidden:NO];
        [self.activityIndicator startAnimating];
        
        // create new dispatch queue in background
        dispatch_queue_t queue = dispatch_queue_create("openActivityIndicatorQueue", NULL);
        
        // send initialization of UIActivityViewController in background
        dispatch_async(queue, ^{
            NSArray *dataToShare = @[self.image,self.descriptionTextView.text];
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:dataToShare applicationActivities:nil];
            activityViewController.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact,UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
            // when UIActivityViewController is finally initialized,
            // hide indicator and present it on main thread
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.activityIndicator stopAnimating];
                [self.activityIndicator setHidden:YES];
                [self presentViewController:activityViewController animated:YES completion:nil];
            });
        });
        //
//        NSArray *items = @[self.image,self.description];
//        UIActivityViewController *vc = [[UIActivityViewController alloc]
//                                        initWithActivityItems:items applicationActivities:nil];
//        vc.excludedActivityTypes = @[UIActivityTypeSaveToCameraRoll,UIActivityTypeAssignToContact,UIActivityTypePrint, UIActivityTypeCopyToPasteboard];
//        [self presentViewController:vc animated:YES completion:nil];
//        
//        [UIView animateWithDuration:0.2 animations:^{
        
//        }];
    }];
    item0.tag = 0;
    item1.tag = 1;
    item2.tag = 2;
    item3.tag = 3;
    
    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1,item2,item3]];

    
    [self.view addSubview:self.uzysSMenu];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Private methods

- (IBAction)handleSingleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else {
        // Zoom out
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
}

- (IBAction)handleDoubleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (self.scrollView.zoomScale == self.scrollView.minimumZoomScale) {
        // Zoom in
        CGPoint center = [tapGestureRecognizer locationInView:self.scrollView];
        CGSize size = CGSizeMake(self.scrollView.bounds.size.width / self.scrollView.maximumZoomScale,
                                 self.scrollView.bounds.size.height / self.scrollView.maximumZoomScale);
        CGRect rect = CGRectMake(center.x - (size.width / 2.0), center.y - (size.height / 2.0), size.width, size.height);
        [self.scrollView zoomToRect:rect animated:YES];
    }
    else {
        // Zoom out
        [self.scrollView zoomToRect:self.scrollView.bounds animated:YES];
    }
}
-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //self.imageView =nil;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
