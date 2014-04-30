//
//  WeatherUploadDetailViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/28/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "WeatherUploadDetailViewController.h"
#import "UzysSlideMenu.h"

@interface WeatherUploadDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextView *describtionTextField;
@property (nonatomic,strong) UzysSlideMenu* uzysSMenu;

@end

@implementation WeatherUploadDetailViewController


- (IBAction)swipeLeft:(id)sender {
    NSLog(@"swiped back");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    self.view.frame = frame;
    self.scrollView.frame = self.view.bounds;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, self.imageView.bounds.size.height);
    self.scrollView.delegate =self;
    
    
    ah__block typeof(self) blockSelf = self;
    UzysSMMenuItem *item0 = [[UzysSMMenuItem alloc] initWithTitle:@"UzysSlide Menu" image:[UIImage imageNamed:@"a0.png"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        
        [UIView animateWithDuration:0.2 animations:^{
            blockSelf.btnMain.frame = CGRectMake(100, 200, blockSelf.btnMain.bounds.size.width, blockSelf.btnMain.bounds.size.height);
        }];
    }];
    
    UzysSMMenuItem *item1 = [[UzysSMMenuItem alloc] initWithTitle:@"Favorite" image:[UIImage imageNamed:@"a1.png"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        [UIView animateWithDuration:0.2 animations:^{
            blockSelf.btnMain.frame = CGRectMake(10, 150, blockSelf.btnMain.bounds.size.width, blockSelf.btnMain.bounds.size.height);
        }];
        
        
    }];
    UzysSMMenuItem *item2 = [[UzysSMMenuItem alloc] initWithTitle:@"Search" image:[UIImage imageNamed:@"a2.png"] action:^(UzysSMMenuItem *item) {
        NSLog(@"Item: %@ menuState : %d", item , blockSelf.uzysSMenu.menuState);
        [UIView animateWithDuration:0.2 animations:^{
            blockSelf.btnMain.frame = CGRectMake(10, 250, blockSelf.btnMain.bounds.size.width, blockSelf.btnMain.bounds.size.height);
        }];
    }];
    item0.tag = 0;
    item1.tag = 1;
    item2.tag = 2;
    
    NSInteger statusbarHeight = 0;

    
    self.uzysSMenu = [[UzysSlideMenu alloc] initWithItems:@[item0,item1,item2]];
    self.uzysSMenu.frame = CGRectMake(self.uzysSMenu.frame.origin.x, self.uzysSMenu.frame.origin.y+ statusbarHeight, self.uzysSMenu.frame.size.width, self.uzysSMenu.frame.size.height);
    
    [self.view addSubview:self.uzysSMenu];
    
}
- (void)dealloc {
    [_scrollView release];
    [_imageView release];
    [_btnMain release];
    [super ah_dealloc];
}
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.uzysSMenu openIconMenu];
    
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doubleTap:(id)sender {
    NSLog(@"toggle menu?");
    [self.uzysSMenu toggleMenu];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
