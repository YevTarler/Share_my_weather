//
//  LMTwitterComposeViewController.m
//  LMAlertViewDemo
//
//  Created by Lee McDermott on 17/11/2013.
//  Copyright (c) 2013 Bestir Ltd. All rights reserved.
//

#import "preUploadViewController.h"
#import "LMEmbeddedViewController.h"
#import "LMAlertView.h"
#import "LocationManager.h"

NSString* const kDescriptionPlaceHolder = @"Hey :) tell me your thoughts about this photo";

@interface preUploadViewController ()
{
    UIActivityIndicatorView *acitivityIndicatorView;
}
@property (nonatomic) BOOL isFirstUpdate;

@end


@implementation preUploadViewController 

#pragma mark - UIViewController methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    //norification for the reverse Geocoding to present the city
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(receivedNotification:) name:kAddressOfCurrentLocationNotificationKey object:nil];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.location = [[LocationManager sharedManager] currentLocation];

    _descriptionTextView.delegate = self;
    _descriptionTextView.text = kDescriptionPlaceHolder;
    _descriptionTextView.textColor = [UIColor lightGrayColor]; //optional
    _imageTaken.image = _imageFromController;
    

	//[attributedText addAttribute:LMFixedTextAttributeName value:[NSNumber numberWithBool:YES] range:substringRange];
	
	UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 137.5, self.view.frame.size.width, 0.5)];
	// This is the default UITableView separator color
	lineView.backgroundColor = [UIColor colorWithHue:360/252 saturation:0.02 brightness:0.80 alpha:1];
	lineView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	
	//[self.headerView addSubview:lineView];
}
- (IBAction)shareButtonPushed:(id)sender {
    self.name = self.nameTextField.text;
    self.description = self.descriptionTextView.text;
    
    if (self.callback)
        self.callback(self.name, self.description, self.locationCity, self.location);
    
    [self.descriptionTextView resignFirstResponder];
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	// When the modal is launched
	// Focus text view/show keyboard immediately
	if (!animated) {
		[self.nameTextField becomeFirstResponder];
	}
}

-(void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion {
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSLog(@"not working unwind");
	UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
	
	LMEmbeddedViewController *alertViewController = (LMEmbeddedViewController *)keyWindow.rootViewController;
	LMAlertView *alertView = alertViewController.alertView;
	
	alertView.keepTopAlignment = YES;
}

#pragma mark - UITableViewDelegate delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.locationCity) {
        self.locationCity = nil;
        cell.detailTextLabel.text = @"None";
        cell.detailTextLabel.textColor = [UIColor grayColor];
        
    }
	else{
	
	cell.detailTextLabel.text = @"Locating…";
	
	acitivityIndicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(255, 12, 20, 20)];
	[acitivityIndicatorView startAnimating];
	// todo - find accurate colour for this
	acitivityIndicatorView.color = cell.detailTextLabel.textColor;
	cell.accessoryView = acitivityIndicatorView;
	
	
	self.location = [[LocationManager sharedManager] currentLocation];
    [[LocationManager sharedManager] getAddressOfCurrentLocation];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.descriptionTextView resignFirstResponder];

    
}
#pragma mark - location shit :


-(void) receivedNotification: (NSNotification*) notification{
    if ([notification.name isEqualToString:kAddressOfCurrentLocationNotificationKey]) {
        NSDictionary *userInfo = notification.userInfo; //get the data
        NSError *error = [userInfo valueForKey:@"error"];
        if (error) {
            [self dismissViewControllerAnimated:NO completion:nil];
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
            return;
        }
        CLPlacemark *placemark = [userInfo valueForKey:@"placemark"];
        self.locationCity = placemark.locality;
        [acitivityIndicatorView stopAnimating];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
       cell.detailTextLabel.text = self.locationCity;
        cell.detailTextLabel.textColor = [[[[UIApplication sharedApplication] delegate] window] tintColor];

}
}


#pragma mark - UITextViewDelegate delegate methods

- (void)textViewDidChange:(UITextView *)textView
{
	NSInteger remainingCharacters = 80 - textView.text.length;
	BOOL postEnabled = (remainingCharacters >= 0);
	
	self.characterCountLabel.textColor = [UIColor colorWithRed:(postEnabled ? 0.0 : 255.0) green:0.0 blue:0.0 alpha:0.5];
	
	self.characterCountLabel.text = [NSString stringWithFormat:@"%li", (long)remainingCharacters];
	
	self.navigationItem.rightBarButtonItem.enabled = postEnabled;
}

#pragma mark - IBActions

- (IBAction)cancelButtonTapped:(id)sesnder
{
	[self.descriptionTextView resignFirstResponder];
	[[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark- TextField delegate
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:kDescriptionPlaceHolder]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor]; //optional
    }
   // [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = kDescriptionPlaceHolder;
        textView.textColor = [UIColor lightGrayColor]; //optional
    }
    [textView resignFirstResponder];
}

@end
