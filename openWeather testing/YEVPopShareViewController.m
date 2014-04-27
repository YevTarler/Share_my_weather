//
//  YEVPopShareViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/24/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "YEVPopShareViewController.h"
#import "FXBlurView.h"

@interface YEVPopShareViewController ()
@property (weak, nonatomic) IBOutlet FXBlurView *bluredView;

@end

@implementation YEVPopShareViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"check");
    self.bluredView.blurRadius = 10;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)blurIt:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
