//
//  imageTakenViewController.m
//  openWeather testing
//
//  Created by Yevgeni Tarler on 4/23/14.
//  Copyright (c) 2014 Eugene Tarler. All rights reserved.
//

#import "imageTakenViewController.h"


@interface imageTakenViewController ()
@property (weak, nonatomic) IBOutlet UILabel *charCountLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextField;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIImageView *BackgroundImageView;
@property (weak, nonatomic) IBOutlet UIView *smallView;

@end

@implementation imageTakenViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _smallView.backgroundColor = [[UIColor clearColor] colorWithAlphaComponent:0.5];
    _descriptionTextField.backgroundColor = [UIColor clearColor];
//    [UIView animateWithDuration:3.5 animations:^{
//        self.blurView.blurRadius = 30;
//    }];
    // Do any additional setup after loading the view.
    if(self.imageTaken) {
        self.photoImageView.image = _imageTaken;
        self.BackgroundImageView.image= _imageTaken; // sould be blurred
    }
}


- (IBAction)shareImageButton:(id)sender {
}

- (IBAction)toggle:(id)sender {
    if (self.blurView.blurRadius < 5)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.blurView.blurRadius = 40;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.blurView.blurRadius = 0;
        }];
    }

}


@end
