//
//  LMTwitterComposeViewController.m
//  LMAlertViewDemo
//
//  Created by Lee McDermott on 17/11/2013.
//  Copyright (c) 2013 Bestir Ltd. All rights reserved.
//
#import <CoreLocation/CoreLocation.h>

extern NSString* const kDescriptionPlaceHolder;

@interface preUploadViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate,UITextFieldDelegate>


@property (nonatomic, strong) IBOutlet UILabel *characterCountLabel;
@property (nonatomic, strong) IBOutlet UITextView *descriptionTextView;

@property (weak, nonatomic) IBOutlet UIImageView *imageTaken;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;
@property (nonatomic,strong) UIImage * imageFromController;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (nonatomic,strong) CLLocation *location;

@property (nonatomic,strong) NSString* name;
@property (nonatomic,strong) NSString* description;
@property (nonatomic,strong) NSString* locationCity;

//block callback:
@property (copy) void(^callback)(NSString *name, NSString *description, NSString *locationCity);

@end
